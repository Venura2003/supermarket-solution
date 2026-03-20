using System;
using System.IO;
using PdfSharpCore.Fonts;

public class CustomFontResolver : IFontResolver
{
    private static readonly string FontFolder = Path.Combine(Directory.GetCurrentDirectory(), "Fonts");
    private static readonly string FontFile = Path.Combine(FontFolder, "Arial.ttf"); // Change to your font file name

    public byte[] GetFont(string faceName)
    {
        // Always return the same font for any faceName
        return File.ReadAllBytes(FontFile);
    }

    public FontResolverInfo ResolveTypeface(string familyName, bool isBold, bool isItalic)
    {
        // Always use the same font for all styles
        return new FontResolverInfo("CustomFont");
    }

    public string DefaultFontName => "CustomFont";
}
