import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart'; // Added
import 'package:pdf/pdf.dart'; // Added
import '../../core/providers/cart_provider.dart';
import 'package:supermarket_flutter_app/core/services/api_service.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/products/providers/product_provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'Cash';
  bool _isProcessing = false;
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _cashReceivedController = TextEditingController();
  double _discountPercentage = 0.0;
  double _cashReceived = 0.0;
  bool _posPrint = true; // Added default POS Print to true

  @override
  void initState() {
    super.initState();
    _discountController.addListener(_updateDiscount);
    _cashReceivedController.addListener(_updateCashReceived); // Added
  }

  @override
  void dispose() {
    _discountController.removeListener(_updateDiscount);
    _discountController.dispose();
    _cashReceivedController.removeListener(_updateCashReceived); // Added
    _cashReceivedController.dispose(); // Added
    super.dispose();
  }

  void _updateDiscount() {
    final val = double.tryParse(_discountController.text) ?? 0.0;
    final safeVal = val.clamp(0.0, 100.0);
    setState(() {
      _discountPercentage = safeVal;
    });
  }

  void _updateCashReceived() { // Added
    final val = double.tryParse(_cashReceivedController.text) ?? 0.0;
    setState(() {
      _cashReceived = val;
    });
  }

  Future<void> _checkout(double finalTotal) async {
    setState(() => _isProcessing = true);
    try {
      final auth = context.read<AuthProvider>();
      if (!auth.isAuthenticated) {
        await auth.checkAuthStatus();
        if (!auth.isAuthenticated) {
          _showError('Not authenticated. Please log in.');
          return;
        }
      }

      final cart = context.read<CartProvider>();
      final subTotal = cart.subTotal;
      final discountAmount = (subTotal * (_discountPercentage / 100));

      final payload = {
        'employeeId': auth.userId,
        'discount': discountAmount,
        'paymentMethod': _paymentMethod,
        'items': cart.items.map((i) => {
          'productId': i.productId,
          'quantity': i.quantity,
          'unitPrice': i.unitPrice
        }).toList(),
      };

      final res = await ApiService.checkout(payload);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final innerData = data is Map ? data['data'] ?? data : data;
        final receiptPath = innerData is Map ? innerData['receiptPath'] : null;

        cart.clear();
        if (mounted) {
          Provider.of<ProductProvider>(context, listen: false).loadProducts();
          
          if (receiptPath != null) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => _ReceiptDialog(receiptPath: receiptPath, autoPrint: _posPrint),
            );
          }
          if (mounted) Navigator.pop(context);
        }
      } else {
        _handleErrorResponse(res);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _handleErrorResponse(dynamic res) {
    try {
      final body = jsonDecode(res.body);
      final msg = body['message'] ?? res.body;
      _showError(msg);
    } catch (_) {
      _showError(res.body ?? 'Unknown error');
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout Failed'),
        content: Text(msg),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final double subTotal = cart.subTotal;
    
    // Tax Calculation (12% VAT)
    final double tax = subTotal * 0.12;
    
    final double discountAmount = (subTotal * (_discountPercentage / 100));
    final double finalTotal = (subTotal + tax - discountAmount).clamp(0.0, double.infinity);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('New Order'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWide = constraints.maxWidth > 800;
          
          Widget cartSummary = Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Summary', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 30),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: isWide ? 400 : 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: cart.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
                              child: Text('${item.quantity}x', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800])),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                            Text('LKR ${(item.quantity * item.unitPrice).toStringAsFixed(2)}'),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );

          Widget paymentSection = Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Payment Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Payment Method
                  const Text('Select Payment Method', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildPaymentOption('Cash', Icons.money),
                      const SizedBox(width: 10),
                      _buildPaymentOption('Card', Icons.credit_card),
                      const SizedBox(width: 10),
                      _buildPaymentOption('Online', Icons.qr_code),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Discount
                  const Text('Discount (%)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      hintText: '0',
                      suffixText: '%',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  if (_paymentMethod == 'Cash') ...[
                    const Text('Cash Tendered', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _cashReceivedController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                        prefixText: 'LKR ',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  // Totals
                  _buildRow('Subtotal', subTotal),
                  _buildRow('Tax (12% VAT)', tax),
                  if (_discountPercentage > 0)
                    _buildRow('Discount', -discountAmount, color: Colors.red),
                  
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text('LKR ${finalTotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[800])),
                    ],
                  ),

                  if (_paymentMethod == 'Cash' && _cashReceived > 0) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Change Due', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text('LKR ${(_cashReceived - finalTotal).clamp(0.0, double.infinity).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  
                  // Auto Print Option
                  SwitchListTile(
                    title: const Text('POS Print (Auto)', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Print receipt immediately after payment'),
                    value: _posPrint,
                    onChanged: (val) => setState(() => _posPrint = val),
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.green,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (_isProcessing || (_paymentMethod == 'Cash' && _cashReceived < finalTotal))
                          ? null 
                          : () => _checkout(finalTotal),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[800],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300], // Explicitly set disabled color so it looks disabled but visible
                        disabledForegroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: _isProcessing 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            (_paymentMethod == 'Cash' && _cashReceived < finalTotal) 
                              ? 'INSUFFICIENT CASH' 
                              : 'CONFIRM PAYMENT',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)
                          ),
                    ),
                  ),
                ],
              ),
            ),
          );

          if (isWide) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: cartSummary),
                  const SizedBox(width: 24),
                  Expanded(flex: 2, child: paymentSection),
                ],
              ),
            );
          } else {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  cartSummary,
                  const SizedBox(height: 16),
                  paymentSection,
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildPaymentOption(String value, IconData icon) {
    bool isSelected = _paymentMethod == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _paymentMethod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green[50] : Colors.white,
            border: Border.all(color: isSelected ? Colors.green : Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? Colors.green[800] : Colors.grey),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.green[800] : Colors.grey[800],
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, double amount, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black54)),
          Text(
            'LKR ${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 15, 
              fontWeight: FontWeight.w600,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDialog extends StatefulWidget {
  final String receiptPath;
  final bool autoPrint;
  const _ReceiptDialog({required this.receiptPath, this.autoPrint = false});

  @override
  State<_ReceiptDialog> createState() => _ReceiptDialogState();
}

class _ReceiptDialogState extends State<_ReceiptDialog> {
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    if (widget.autoPrint) {
      // Trigger print after dialog is shown
      Future.delayed(const Duration(milliseconds: 500), _handlePrint);
    }
  }

  Future<void> _handlePrint() async {
    setState(() => _isPrinting = true);
    try {
      final path = await ApiService.downloadReceipt(widget.receiptPath, 'receipt.pdf');
      if (path != null) {
        final file = File(path);
        final bytes = await file.readAsBytes();
        await Printing.layoutPdf(
          onLayout: (_) => bytes,
          name: 'Receipt - ${DateTime.now().millisecondsSinceEpoch}',
        );
      }
    } catch (e) {
      debugPrint('Error printing receipt: $e');
      if (mounted) {
         try {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Print Error: $e')));
         } catch (_) {}
      }
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Future<void> _openReceipt() async {
    final pdfUrl = widget.receiptPath; // This should be the full URL to the PDF file
    if (await canLaunchUrl(Uri.parse(pdfUrl))) {
      await launchUrl(Uri.parse(pdfUrl), mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $pdfUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      content: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text('Payment Successful!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_isPrinting)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Printing receipt...', style: TextStyle(color: Colors.blue)),
              )
            else
              const Text('The transaction has been completed.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handlePrint,
                    icon: const Icon(Icons.print),
                    label: const Text('POS Print'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () { _openReceipt(); },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('View PDF'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
               child: const Text('Close', style: TextStyle(color: Colors.grey))
            ),
          ],
        ),
      ),
    );
  }
}
