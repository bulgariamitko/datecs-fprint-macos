namespace WindowsFormsApp1
{
    partial class Form1
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
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

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.button1 = new System.Windows.Forms.Button();
            this.label1 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.button2 = new System.Windows.Forms.Button();
            this.button3 = new System.Windows.Forms.Button();
            this.button4 = new System.Windows.Forms.Button();
            this.label3 = new System.Windows.Forms.Label();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.button7 = new System.Windows.Forms.Button();
            this.button6 = new System.Windows.Forms.Button();
            this.tbStatuses = new System.Windows.Forms.TextBox();
            this.label7 = new System.Windows.Forms.Label();
            this.tbOutputData = new System.Windows.Forms.TextBox();
            this.label6 = new System.Windows.Forms.Label();
            this.tbInputData = new System.Windows.Forms.TextBox();
            this.label5 = new System.Windows.Forms.Label();
            this.tbCommand = new System.Windows.Forms.TextBox();
            this.label4 = new System.Windows.Forms.Label();
            this.button5 = new System.Windows.Forms.Button();
            this.cbxPort = new System.Windows.Forms.ComboBox();
            this.cbxDevice = new System.Windows.Forms.ComboBox();
            this.cbxSpeed = new System.Windows.Forms.ComboBox();
            this.lbPort = new System.Windows.Forms.Label();
            this.lbSpeed = new System.Windows.Forms.Label();
            this.label10 = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Location = new System.Drawing.Point(349, 60);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(210, 31);
            this.button1.TabIndex = 0;
            this.button1.Text = "GetSerialNumber (set params in code)";
            this.button1.UseVisualStyleBackColor = true;
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // label1
            // 
            this.label1.AutoSize = true;
            this.label1.Location = new System.Drawing.Point(346, 103);
            this.label1.Name = "label1";
            this.label1.Size = new System.Drawing.Size(35, 13);
            this.label1.TabIndex = 1;
            this.label1.Text = "label1";
            // 
            // label2
            // 
            this.label2.AutoSize = true;
            this.label2.Location = new System.Drawing.Point(346, 119);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(35, 13);
            this.label2.TabIndex = 2;
            this.label2.Text = "label2";
            // 
            // button2
            // 
            this.button2.Location = new System.Drawing.Point(27, 149);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(210, 31);
            this.button2.TabIndex = 3;
            this.button2.Text = "Open port (set params in code)";
            this.button2.UseVisualStyleBackColor = true;
            this.button2.Click += new System.EventHandler(this.button2_Click);
            // 
            // button3
            // 
            this.button3.Location = new System.Drawing.Point(27, 196);
            this.button3.Name = "button3";
            this.button3.Size = new System.Drawing.Size(210, 31);
            this.button3.TabIndex = 4;
            this.button3.Text = "Execute file (set file in code)";
            this.button3.UseVisualStyleBackColor = true;
            this.button3.Click += new System.EventHandler(this.button3_Click);
            // 
            // button4
            // 
            this.button4.Location = new System.Drawing.Point(27, 584);
            this.button4.Name = "button4";
            this.button4.Size = new System.Drawing.Size(210, 31);
            this.button4.TabIndex = 5;
            this.button4.Text = "Close port";
            this.button4.UseVisualStyleBackColor = true;
            this.button4.Click += new System.EventHandler(this.button4_Click);
            // 
            // label3
            // 
            this.label3.AutoSize = true;
            this.label3.Font = new System.Drawing.Font("Microsoft Sans Serif", 12F, System.Drawing.FontStyle.Underline, System.Drawing.GraphicsUnit.Point, ((byte)(204)));
            this.label3.Location = new System.Drawing.Point(23, 9);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(462, 20);
            this.label3.TabIndex = 6;
            this.label3.Text = "Make sure \"FPrintWIN.dll\" is in the debug exe folder of this demo";
            // 
            // groupBox1
            // 
            this.groupBox1.Controls.Add(this.button7);
            this.groupBox1.Controls.Add(this.button6);
            this.groupBox1.Controls.Add(this.tbStatuses);
            this.groupBox1.Controls.Add(this.label7);
            this.groupBox1.Controls.Add(this.tbOutputData);
            this.groupBox1.Controls.Add(this.label6);
            this.groupBox1.Controls.Add(this.tbInputData);
            this.groupBox1.Controls.Add(this.label5);
            this.groupBox1.Controls.Add(this.tbCommand);
            this.groupBox1.Controls.Add(this.label4);
            this.groupBox1.Controls.Add(this.button5);
            this.groupBox1.Location = new System.Drawing.Point(27, 252);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(553, 312);
            this.groupBox1.TabIndex = 14;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Execute custom command ( requires opened port )";
            // 
            // button7
            // 
            this.button7.Location = new System.Drawing.Point(322, 213);
            this.button7.Name = "button7";
            this.button7.Size = new System.Drawing.Size(210, 31);
            this.button7.TabIndex = 24;
            this.button7.Text = "custom_Command_03";
            this.button7.UseVisualStyleBackColor = true;
            this.button7.Click += new System.EventHandler(this.button7_Click);
            // 
            // button6
            // 
            this.button6.Location = new System.Drawing.Point(322, 176);
            this.button6.Name = "button6";
            this.button6.Size = new System.Drawing.Size(210, 31);
            this.button6.TabIndex = 23;
            this.button6.Text = "custom_Command_02";
            this.button6.UseVisualStyleBackColor = true;
            this.button6.Click += new System.EventHandler(this.button6_Click);
            // 
            // tbStatuses
            // 
            this.tbStatuses.Location = new System.Drawing.Point(92, 113);
            this.tbStatuses.Name = "tbStatuses";
            this.tbStatuses.Size = new System.Drawing.Size(440, 20);
            this.tbStatuses.TabIndex = 22;
            // 
            // label7
            // 
            this.label7.AutoSize = true;
            this.label7.Location = new System.Drawing.Point(34, 116);
            this.label7.Name = "label7";
            this.label7.Size = new System.Drawing.Size(51, 13);
            this.label7.TabIndex = 21;
            this.label7.Text = "Statuses:";
            // 
            // tbOutputData
            // 
            this.tbOutputData.Location = new System.Drawing.Point(92, 87);
            this.tbOutputData.Name = "tbOutputData";
            this.tbOutputData.Size = new System.Drawing.Size(440, 20);
            this.tbOutputData.TabIndex = 20;
            // 
            // label6
            // 
            this.label6.AutoSize = true;
            this.label6.Location = new System.Drawing.Point(19, 90);
            this.label6.Name = "label6";
            this.label6.Size = new System.Drawing.Size(66, 13);
            this.label6.TabIndex = 19;
            this.label6.Text = "Output data:";
            // 
            // tbInputData
            // 
            this.tbInputData.Location = new System.Drawing.Point(92, 61);
            this.tbInputData.Name = "tbInputData";
            this.tbInputData.Size = new System.Drawing.Size(440, 20);
            this.tbInputData.TabIndex = 18;
            // 
            // label5
            // 
            this.label5.AutoSize = true;
            this.label5.Location = new System.Drawing.Point(27, 63);
            this.label5.Name = "label5";
            this.label5.Size = new System.Drawing.Size(58, 13);
            this.label5.TabIndex = 17;
            this.label5.Text = "Input data:";
            // 
            // tbCommand
            // 
            this.tbCommand.Location = new System.Drawing.Point(92, 35);
            this.tbCommand.MaxLength = 4;
            this.tbCommand.Name = "tbCommand";
            this.tbCommand.Size = new System.Drawing.Size(118, 20);
            this.tbCommand.TabIndex = 16;
            // 
            // label4
            // 
            this.label4.AutoSize = true;
            this.label4.Location = new System.Drawing.Point(28, 38);
            this.label4.Name = "label4";
            this.label4.Size = new System.Drawing.Size(57, 13);
            this.label4.TabIndex = 15;
            this.label4.Text = "Command:";
            // 
            // button5
            // 
            this.button5.Location = new System.Drawing.Point(322, 139);
            this.button5.Name = "button5";
            this.button5.Size = new System.Drawing.Size(210, 31);
            this.button5.TabIndex = 14;
            this.button5.Text = "custom_Command_01";
            this.button5.UseVisualStyleBackColor = true;
            this.button5.Click += new System.EventHandler(this.button5_Click);
            // 
            // cbxPort
            // 
            this.cbxPort.DisplayMember = "1";
            this.cbxPort.FormattingEnabled = true;
            this.cbxPort.ItemHeight = 13;
            this.cbxPort.Items.AddRange(new object[] {
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12",
            "13",
            "14",
            "15",
            "16",
            "17",
            "18",
            "19",
            "20",
            "21",
            "22",
            "23",
            "24",
            "25",
            "26",
            "27",
            "28",
            "29",
            "30",
            "31",
            "32",
            "33",
            "34",
            "35",
            "36",
            "37",
            "38",
            "39",
            "40",
            "41",
            "42",
            "43",
            "44",
            "45",
            "46",
            "47",
            "48",
            "49",
            "50"});
            this.cbxPort.Location = new System.Drawing.Point(27, 66);
            this.cbxPort.Name = "cbxPort";
            this.cbxPort.Size = new System.Drawing.Size(120, 21);
            this.cbxPort.TabIndex = 15;
            this.cbxPort.ValueMember = "1";
            // 
            // cbxDevice
            // 
            this.cbxDevice.FormattingEnabled = true;
            this.cbxDevice.Items.AddRange(new object[] {
            "ETH_FP60",
            "FBH_FP550",
            "FBH_TM_T260",
            "FBH_FP700",
            "FBH_FP700TCP",
            "FBH_FP60",
            "FBH_FP60TCP",
            "FBH_FMP350",
            "FBH_DP_25_X",
            "FBH_FMP_350_X",
            "FBH_FP_650_X",
            "FBH_FP_700_X",
            "FBH_MP55LD",
            "FBH_DP50",
            "FBH_DP55",
            "FBH_DP55_S",
            "SRB_FP600KL",
            "SRB_DP05KL",
            "SRB_DP25KL",
            "SRB_DP35KL",
            "SRB_DP45KL",
            "GEO_DP25",
            "GEO_DP05",
            "MLD_DP25",
            "MLD_DP150",
            "MLD_WP500",
            "BGR_DP05",
            "BGR_DP25",
            "BGR_DP35",
            "BGR_DP150",
            "BGR_WP50",
            "BGR_WP500X",
            "BGR_DP25X",
            "BGR_DP150X",
            "BGR_WP50X",
            "BGR_DP05C X",
            "BGR_DP15",
            "BGR_DP05B",
            "BGR_FP650",
            "BGR_FP800",
            "BGR_FP2000",
            "BGR_FMP350X",
            "BGR_FP700X",
            "BGR_FMP55X",
            "BGR_FP700",
            "MNE_FP550",
            "MNE_FP1000KL"});
            this.cbxDevice.Location = new System.Drawing.Point(27, 111);
            this.cbxDevice.Name = "cbxDevice";
            this.cbxDevice.Size = new System.Drawing.Size(246, 21);
            this.cbxDevice.TabIndex = 16;
            this.cbxDevice.SelectedIndexChanged += new System.EventHandler(this.cbxDevice_SelectedIndexChanged);
            // 
            // cbxSpeed
            // 
            this.cbxSpeed.FormattingEnabled = true;
            this.cbxSpeed.Items.AddRange(new object[] {
            "4800  ",
            "9600  ",
            "14400 ",
            "19200 ",
            "28800 ",
            "38400 ",
            "57600 ",
            "115200"});
            this.cbxSpeed.Location = new System.Drawing.Point(153, 66);
            this.cbxSpeed.Name = "cbxSpeed";
            this.cbxSpeed.Size = new System.Drawing.Size(120, 21);
            this.cbxSpeed.TabIndex = 17;
            // 
            // lbPort
            // 
            this.lbPort.AutoSize = true;
            this.lbPort.Location = new System.Drawing.Point(24, 50);
            this.lbPort.Name = "lbPort";
            this.lbPort.Size = new System.Drawing.Size(26, 13);
            this.lbPort.TabIndex = 18;
            this.lbPort.Text = "Port";
            // 
            // lbSpeed
            // 
            this.lbSpeed.AutoSize = true;
            this.lbSpeed.Location = new System.Drawing.Point(150, 50);
            this.lbSpeed.Name = "lbSpeed";
            this.lbSpeed.Size = new System.Drawing.Size(38, 13);
            this.lbSpeed.TabIndex = 19;
            this.lbSpeed.Text = "Speed";
            // 
            // label10
            // 
            this.label10.AutoSize = true;
            this.label10.Location = new System.Drawing.Point(24, 95);
            this.label10.Name = "label10";
            this.label10.Size = new System.Drawing.Size(46, 13);
            this.label10.TabIndex = 20;
            this.label10.Text = "Devices";
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(613, 659);
            this.Controls.Add(this.label10);
            this.Controls.Add(this.lbSpeed);
            this.Controls.Add(this.lbPort);
            this.Controls.Add(this.cbxSpeed);
            this.Controls.Add(this.cbxDevice);
            this.Controls.Add(this.cbxPort);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.label3);
            this.Controls.Add(this.button4);
            this.Controls.Add(this.button3);
            this.Controls.Add(this.button2);
            this.Controls.Add(this.label2);
            this.Controls.Add(this.label1);
            this.Controls.Add(this.button1);
            this.Name = "Form1";
            this.Text = "Form1";
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Label label1;
        private System.Windows.Forms.Label label2;
        private System.Windows.Forms.Button button2;
        private System.Windows.Forms.Button button3;
        private System.Windows.Forms.Button button4;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.TextBox tbOutputData;
        private System.Windows.Forms.Label label6;
        private System.Windows.Forms.TextBox tbInputData;
        private System.Windows.Forms.Label label5;
        private System.Windows.Forms.TextBox tbCommand;
        private System.Windows.Forms.Label label4;
        private System.Windows.Forms.Button button5;
        private System.Windows.Forms.TextBox tbStatuses;
        private System.Windows.Forms.Label label7;
        private System.Windows.Forms.Button button7;
        private System.Windows.Forms.Button button6;
        private System.Windows.Forms.ComboBox cbxPort;
        private System.Windows.Forms.ComboBox cbxDevice;
        private System.Windows.Forms.ComboBox cbxSpeed;
        private System.Windows.Forms.Label lbPort;
        private System.Windows.Forms.Label lbSpeed;
        private System.Windows.Forms.Label label10;
    }
}

