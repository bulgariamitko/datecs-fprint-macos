using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;
using System.Runtime.InteropServices;

namespace WindowsFormsApp1
{
    public partial class Form1 : Form
    {

        [DllImport("FPrintWIN.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern int GET_SERIAL_NUMBER_Ex(
             byte ComPort,
             int BaudRate,
             byte StopBits,
             byte Parity,
             byte ByteSize,
             int DevIndex,
             int Logical,
             byte[] Serial_num
            );
        [DllImport("FPrintWIN.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern int GET_SERIAL_NUMBER(
             byte ComPort,
             int BaudRate,
             byte StopBits,
             byte Parity,
             byte ByteSize,
             int DevIndex,
             int Logical,
            [MarshalAs(UnmanagedType.BStr)] ref string Serial_num
            );

        [DllImport("FPrintWIN.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern int OPEN_PORT_Ex(
                byte ComPort,
                int BaudRate,
                byte StopBits,
                byte Parity,
                byte ByteSize,
                int DevIndex,
                int Logical,
                byte[] Serial_key
               );

        [DllImport("FPrintWIN.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern int EXECUTE_FILE_Ex(
                byte[] executeFileName,
                byte[] answerFileName,
                bool dosText,
                bool classicAnswer
            );

        [DllImport("FPrintWIN.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern int CLOSE_PORT();


        [DllImport("FPrintWIN.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern int custom_Command_01(
             int cmd,
             byte[] In_data,
             int In_dataSize,
             byte[] Out_data,
             ref int Out_datasize,
             byte[] statusBytes,
             ref int statusBytesSize
            );
        [DllImport("FPrintWIN.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern int custom_Command_02(
             int cmd,
             byte[] statusBytes,
             ref int statusBytesSize
            );
        [DllImport("FPrintWIN.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern int custom_Command_03(
             int cmd,
             byte[] In_data,
             int In_dataSize,
             byte[] Out_data,
             ref int Out_datasize,
             byte[] statusBits_AsText,
             ref int statusBytesAsText_Size
            );

        [DllImport("FPrintWIN.dll", CharSet = CharSet.Ansi, CallingConvention = CallingConvention.StdCall)]
        public static extern int EXECUTE_STRING_Ex(
             byte[] IOstr
            );

        int res = 0;
        int out_datasize;
        byte[] Out_data = new byte[220];

        byte[] statuses = new byte[8];
        int statuses_datasize;

        byte[] statusBits_AsText = new byte[71];
        int statusBits__datasize;

        int devIndex = 0;

        public Form1()
        {
            InitializeComponent();
            cbxPort.SelectedIndex = 2;
            cbxSpeed.SelectedIndex = 7;
            cbxDevice.SelectedIndex = 26;
            
        }

        private void button1_Click(object sender, EventArgs e)
        {
            byte[] SerialB = new byte[10];
            res = GET_SERIAL_NUMBER_Ex(Convert.ToByte(cbxPort.Text), Convert.ToInt32(cbxSpeed.Text), 0, 0, 8, devIndex, 1, SerialB);
            label1.Text = Encoding.ASCII.GetString(SerialB).TrimEnd(new char[] { '\0' });

            string SerialS = "";
            res = GET_SERIAL_NUMBER(Convert.ToByte(cbxPort.Text), Convert.ToInt32(cbxSpeed.Text), 0, 0, 8, devIndex, 1, ref SerialS);
            label2.Text = SerialS;
        }

        private void button2_Click(object sender, EventArgs e)
        {
            string SerialKey = "";// /* serial is no longer used and can be empty*/
            res = OPEN_PORT_Ex(Convert.ToByte(cbxPort.Text), Convert.ToInt32(cbxSpeed.Text), 0, 0, 8, devIndex, 1, Encoding.ASCII.GetBytes(SerialKey));

        }

        private void button3_Click(object sender, EventArgs e)
        {
            string execFile = @"C:\temp\execfileTest.txt";
            string answerFile = @"C:\temp\ansfileTest.txt";
            res = EXECUTE_FILE_Ex(Encoding.ASCII.GetBytes(execFile), Encoding.ASCII.GetBytes(answerFile), false, false);

            MessageBox.Show(Convert.ToString(res));
        }

        private void button4_Click(object sender, EventArgs e)
        {
            res = CLOSE_PORT();
        }

        private void button5_Click(object sender, EventArgs e)
        {
            res = custom_Command_01(Convert.ToInt32(tbCommand.Text),
                                    Encoding.ASCII.GetBytes(tbInputData.Text),
                                    tbInputData.Text.Length,
                                    Out_data,
                                    ref out_datasize,
                                    statuses,
                                    ref statuses_datasize);

            tbOutputData.Text = "";
            if (res < 0)
            {
                MessageBox.Show(Convert.ToString(res));
                return;
            }
            tbStatuses.Text = "";
            tbOutputData.Text = Encoding.ASCII.GetString(Out_data, 0, out_datasize);
            for (int i = 0; i < statuses_datasize; i++)
            {
                tbStatuses.Text = tbStatuses.Text + Convert.ToString(statuses[i]) + " ";
            }

        }

        private void button6_Click(object sender, EventArgs e)
        {
            res = custom_Command_02(Convert.ToInt32(tbCommand.Text),
                                    statuses,
                                    ref statuses_datasize);

            tbOutputData.Text = "";
            if (res < 0)
            {
                MessageBox.Show(Convert.ToString(res));
                return;
            }
            tbStatuses.Text = "";
            for (int i = 0; i < statuses_datasize; i++)
            {
                tbStatuses.Text = tbStatuses.Text + Convert.ToString(statuses[i]) + " ";
            }
        }

        private void button7_Click(object sender, EventArgs e)
        {
            res = custom_Command_03(Convert.ToInt32(tbCommand.Text),
                                    Encoding.ASCII.GetBytes(tbInputData.Text),
                                    tbInputData.Text.Length,
                                    Out_data,
                                    ref out_datasize,
                                    statusBits_AsText,
                                    ref statusBits__datasize);

            tbOutputData.Text = "";
            if (res < 0)
            {
                MessageBox.Show(Convert.ToString(res));
                return;
            }
            tbStatuses.Text = "";
            tbOutputData.Text = Encoding.ASCII.GetString(Out_data, 0, out_datasize);
            tbStatuses.Text = Encoding.ASCII.GetString(statusBits_AsText);
        }

        private void cbxDevice_SelectedIndexChanged(object sender, EventArgs e)
        {
            switch (cbxDevice.SelectedIndex)
            {
                case 0: { devIndex = 3001; break; }  //ETH_FP60
                case 1: { devIndex = 4001; break; }//FBH_FP550
                case 2: { devIndex = 4002; break; }//FBH_TM_T260
                case 3: { devIndex = 4003; break; }//FBH_FP700
                case 4: { devIndex = 4004; break; }//FBH_FP700TCP
                case 5: { devIndex = 4005; break; }//FBH_FP60
                case 6: { devIndex = 4006; break; }//FBH_FP60TCP
                case 7: { devIndex = 4007; break; }//FBH_FMP350
                case 8: { devIndex = 4008; break; }//FBH_DP_25_X
                case 9: { devIndex = 4009; break; }//FBH_FMP_350_X

                case 10: { devIndex = 4010; break; }  //FBH_FP_650_X
                case 11: { devIndex = 4011; break; }//FBH_FP_700_X
                case 12: { devIndex = 4012; break; }//FBH_MP55LD
                case 13: { devIndex = 4101; break; }//FBH_DP50
                case 14: { devIndex = 4102; break; }
                case 15: { devIndex = 4103; break; }//FBH DP55S
                case 16: { devIndex = 6001; break; }
                case 17: { devIndex = 6002; break; }
                case 18: { devIndex = 6003; break; }
                case 19: { devIndex = 6004; break; }

                case 20: { devIndex = 6005; break; }
                case 21: { devIndex = 7001; break; }
                case 22: { devIndex = 7002; break; }
                case 23: { devIndex = 8001; break; }
                case 24: { devIndex = 8002; break; }
                case 25: { devIndex = 8003; break; }
                case 26: { devIndex = 10001; break; }
                case 27: { devIndex = 10002; break; }
                case 28: { devIndex = 10003; break; }
                case 29: { devIndex = 10004; break; }
                case 30: { devIndex = 10005; break; }
                case 31: { devIndex = 10006; break; }
                case 32: { devIndex = 10007; break; }
                case 33: { devIndex = 10008; break; }
                case 34: { devIndex = 10009; break; }
                case 35: { devIndex = 10010; break; }
                case 36: { devIndex = 10011; break; }
                case 37: { devIndex = 10012; break; }
                case 38: { devIndex = 11001; break; }
                case 39: { devIndex = 11002; break; }
                case 40: { devIndex = 11003; break; }
                case 41: { devIndex = 11004; break; }
                case 42: { devIndex = 11005; break; }
                case 43: { devIndex = 11006; break; }
                case 44: { devIndex = 11007; break; }
                

            }
        }
    }
}    

       
