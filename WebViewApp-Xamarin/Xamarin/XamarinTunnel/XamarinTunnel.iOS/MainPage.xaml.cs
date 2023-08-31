using Microsoft.Intune.Tunnel.MAM.iOS;
using Xamarin.Forms;

namespace XamarinTunnel.iOS
{	
	public partial class MainPage : ContentPage
	{
        MicrosoftTunnelStatus _status;
        public MainPage()
        {
            InitializeComponent();
            TunnelDelegate.SharedDelegate.StatusChanged += SharedDelegate_StatusChanged;

        }

        private void SharedDelegate_StatusChanged(object sender, MicrosoftTunnelStatus e)
        {
            _status = e;
            status.Text = e.ToString();

            if (e == MicrosoftTunnelStatus.Connected)
            {
                toggleConnection.Text = "Disconnect";
                toggleConnection.IsEnabled = true;
            }
            else if (e == MicrosoftTunnelStatus.Disconnected)
            {
                toggleConnection.Text = "Connect";
                toggleConnection.IsEnabled = true;
            }
            else
            {
                toggleConnection.Text = "...";
                toggleConnection.IsEnabled = false;
            }
        }

        void Button1_Clicked(System.Object sender, System.EventArgs e)
        {
            url.Text = "https://www.bing.com";
        }

        void Button2_Clicked(System.Object sender, System.EventArgs e)
        {
            url.Text = "https://www.ipchicken.com";
        }

        void toggleConnection_Clicked(System.Object sender, System.EventArgs e)
        {
            if (_status == MicrosoftTunnelStatus.Connected)
            {
                TunnelDelegate.SharedDelegate.Disconnect();
            }
            else
            {
                TunnelDelegate.SharedDelegate.Connect();
            }
        }

        void refresh_Clicked(System.Object sender, System.EventArgs e)
        {
            webView.Reload();
        }
    }
}

