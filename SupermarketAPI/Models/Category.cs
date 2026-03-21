using System.ComponentModel.DataAnnotations;

namespace SupermarketAPI.Models
{
    public class Category
    {
        public int Id { get; set; }

        [Required]
        [StringLength(128)]
        public string Name { get; set; } = string.Empty;

        [StringLength(1024)]
        public string? ImageUrl { get; set; }
    }
}
