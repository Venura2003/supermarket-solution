using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using SupermarketAPI.Models;

namespace SupermarketAPI.Services
{
    public class NotificationService : INotificationService
    {
        private readonly List<Notification> _notifications = new List<Notification>();

        public Task<IEnumerable<Notification>> GetNotificationsAsync()
        {
            // TODO: Replace with real data access
            return Task.FromResult(_notifications.AsEnumerable());
        }

        public Task MarkAsReadAsync(int id)
        {
            // TODO: Replace with real data access
            var notification = _notifications.FirstOrDefault(n => n.Id == id);
            if (notification != null)
            {
                notification.IsRead = true;
            }
            return Task.CompletedTask;
        }
    }
}
