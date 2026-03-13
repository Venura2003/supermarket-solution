using FluentValidation;
using SupermarketAPI.DTOs;

namespace SupermarketAPI.Validators
{
    public class CreateSaleDtoValidator : AbstractValidator<CreateSaleDto>
    {
        public CreateSaleDtoValidator()
        {
            RuleFor(x => x.TotalAmount)
                .GreaterThan(0).WithMessage("Total amount must be greater than 0");

            RuleFor(x => x.DiscountAmount)
                .GreaterThanOrEqualTo(0).WithMessage("Discount amount cannot be negative")
                .LessThanOrEqualTo(x => x.TotalAmount).WithMessage("Discount cannot exceed total amount");

            RuleFor(x => x.PaymentMethod)
                .NotEmpty().WithMessage("Payment method is required")
                .MaximumLength(50).WithMessage("Payment method cannot exceed 50 characters");

            RuleFor(x => x.Notes)
                .MaximumLength(500).WithMessage("Notes cannot exceed 500 characters");

            RuleFor(x => x.Items)
                .NotEmpty().WithMessage("At least one item is required");

            RuleForEach(x => x.Items)
                .SetValidator(new CreateSaleItemDtoValidator());
        }
    }

    public class CreateSaleItemDtoValidator : AbstractValidator<CreateSaleItemDto>
    {
        public CreateSaleItemDtoValidator()
        {
            RuleFor(x => x.ProductId)
                .GreaterThan(0).WithMessage("Valid product ID is required");

            RuleFor(x => x.Quantity)
                .GreaterThan(0).WithMessage("Quantity must be greater than 0");

            RuleFor(x => x.UnitPrice)
                .GreaterThan(0).WithMessage("Unit price must be greater than 0");

            RuleFor(x => x.Discount)
                .GreaterThanOrEqualTo(0).WithMessage("Discount cannot be negative");

            RuleFor(x => x.LineTotal)
                .GreaterThan(0).WithMessage("Line total must be greater than 0");
        }
    }
}