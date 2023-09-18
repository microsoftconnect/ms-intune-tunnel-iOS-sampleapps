using System;
using Microsoft.Intune.Tunnel.MAM.iOS;
using System.Collections.Generic;
using Microsoft.Intune.MAM;

namespace XamarinTunnel.iOS
{
    public class TunnelDelegate : MicrosoftTunnelDelegate
    {
        private TunnelDelegate()
        {
        }

        private static TunnelDelegate _sharedDelegate = null;
        public static TunnelDelegate SharedDelegate
        {
            get
            {
                if (_sharedDelegate == null)
                {
                    _sharedDelegate = new TunnelDelegate
                    {
                        _config = new Dictionary<string, string>
                        {
                            //{ MicrosoftTunnelLogging.MicrosoftTunnel, MicrosoftTunnelLogging.Debug },
                            //{ MicrosoftTunnelLogging.Connect, MicrosoftTunnelLogging.Debug }
                        },
                        _api = MicrosoftTunnel.SharedInstance
                    };
                }
                return _sharedDelegate;
            }
        }

        private Dictionary<string, string> _config = new Dictionary<string, string>();
        private readonly LogDelegate _logDelegate = new LogDelegate();
        private readonly EnrollmentDelegate _enrollmentDelegate = new EnrollmentDelegate();
        private MicrosoftTunnel _api;
        private bool _initialized = false;

        public event EventHandler<MicrosoftTunnelStatus> StatusChanged;

        public void Launch()
        {
            _api = _api ?? throw new InvalidOperationException("API is null");

            IntuneMAMEnrollmentManager.Instance.Delegate = _enrollmentDelegate;

            if (!_api.LaunchEnrollment())
            {
                Initialize();
            }
        }

        public void Connect()
        {
            _api.Connect();
        }

        public void Disconnect()
        {
            _api.Disconnect();
        }

        protected void Initialize()
        {
            lock (this)
            {
                if (!_initialized)
                {
                    _api.MicrosoftTunnelInitialize(this, _logDelegate, _config);
                    _initialized = true;
                }
            }
        }

        public override void OnInitialized()
        {
            Connect();
        }

        public override void OnReceivedEvent(MicrosoftTunnelStatus e)
        {
            StatusChanged?.Invoke(this, e);
        }

        public override void OnConnected()
        {
        }

        public override void OnDisconnected()
        {
        }

        public override void OnError(MicrosoftTunnelError e)
        {
        }

        public override void OnReconnecting()
        {
        }

        public override void OnUserInteractionRequired()
        {
        }

        private class EnrollmentDelegate : IntuneMAMEnrollmentDelegate
        {
            public override void EnrollmentRequestWithStatus(IntuneMAMEnrollmentStatus status)
            {
                if (status.DidSucceed)
                {
                    SharedDelegate.Initialize();
                }
            }
        }
    }

    public class LogDelegate : MicrosoftTunnelLogDelegate
    {
        public override void LogMessage(uint level, uint logClass, string pTime, string pLevel, string pClassLabel, string pLog)
        {
            Console.WriteLine(pLog);
        }
    }
}

