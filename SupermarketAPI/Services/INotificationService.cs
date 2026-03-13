using System.Collections.Generic;
using System.Threading.Tasks;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    public interface INotificationService
    {
        Task<IEnumerable<Notification>> GetNotificationsAsync();
        Task MarkAsReadAsync(int id);
    }
}
