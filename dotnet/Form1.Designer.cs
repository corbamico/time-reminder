namespace reminder;

partial class Form1
{
    /// <summary>
    ///  Required designer variable.
    /// </summary>
    private System.ComponentModel.IContainer components = null;

    /// <summary>
    ///  Clean up any resources being used.
    /// </summary>
    /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    protected override void Dispose(bool disposing)
    {
        if (disposing && (components != null))
        {
            components.Dispose();
        }
        base.Dispose(disposing);
    }

    #region Windows Form Designer generated code

    class TLabel : System.Windows.Forms.Label
    {
        private const int HTTRANSPARENT = -1;
        protected override void WndProc(ref Message m)
        {
            switch (m.Msg)
            {
                case WM_NCHITTEST:
                    m.Result = (IntPtr)HTTRANSPARENT;
                    return;
            }
            base.WndProc(ref m);
        }
    }

    /// <summary>
    ///  Required method for Designer support - do not modify
    ///  the contents of this method with the code editor.
    /// </summary>
    private void InitializeComponent()
    {
        var cmdArgs = Environment.GetCommandLineArgs();
        if (cmdArgs.Length == 2)
        {
            int minutes;
            if ((int.TryParse(cmdArgs[1], out minutes))
               && (minutes > 0)
               && (minutes < 24 * 60))
            {
                _target = DateTime.Now + TimeSpan.FromMinutes(minutes);
            }
        }

        this.components = new System.ComponentModel.Container();
        this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
        this.ClientSize = new System.Drawing.Size(16, 16);
        this.Text = "elapse time...";

        this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.None;
        this.BackColor = Color.Green;

        //this._lbTimer = new System.Windows.Forms.Label();
        this._lbTimer = new TLabel()
        {
            AutoSize = true,
            TextAlign = ContentAlignment.MiddleCenter,
            Dock = DockStyle.None,
            Name = "_lbTimer",
            //Size = new System.Drawing.Size(48, 12),
            BackColor = Color.Transparent,
            ForeColor = Color.White,
            Text = "剩余       ",
            Location = new System.Drawing.Point(0, 7),
        };

        this.TopMost = true;
        this.Controls.Add(this._lbTimer);

        this._timer = new System.Windows.Forms.Timer(this.components)
        {
            Interval = 1000,
        };        
        this._timer.Tick += this.tick;
        this._timer.Start();
    }
    private void tick(Object obj, EventArgs args)
    {
        var now = DateTime.Now;
        this.Invoke(new Action(() =>
        {
            if (now < _target)
            {
                this.BackColor = Color.Green;
                _lbTimer.Text = string.Format("剩余 {0}", (_target - now).ToString(@"hh\:mm\:ss"));
            }
            else
            {
                this.BackColor = Color.Red;
                _lbTimer.Text = string.Format("超时 {0}", (_target - now).ToString(@"hh\:mm\:ss"));
            }
        }));
    }

    /*
    Constants in Windows API
    0x84 = WM_NCHITTEST - Mouse Capture Test
    0x1 = HTCLIENT - Application Client Area
    0x2 = HTCAPTION - Application Title Bar
    */
    private const int WM_NCHITTEST = 0x84;
    private const int HTCLIENT = 0x1;
    private const int HTCAPTION = 0x2;
    protected override void WndProc(ref Message m)
    {
        switch (m.Msg)
        {
            case WM_NCHITTEST:
                base.WndProc(ref m);
                if ((int)m.Result == HTCLIENT)
                    m.Result = (IntPtr)HTCAPTION;
                return;
        }
        base.WndProc(ref m);
    }

    //private System.Windows.Forms.Label _lbTimer;
    private TLabel _lbTimer;
    private System.Windows.Forms.Timer _timer;
    private DateTime _target = DateTime.Now + TimeSpan.FromMinutes(30);

    #endregion
}
