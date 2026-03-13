namespace SupermarketAPI.Models.DTOs
{
    public class ChangePasswordRequest
    {
        public int UserId { get; set; }
        public string NewPassword { get; set; }
    }
}
