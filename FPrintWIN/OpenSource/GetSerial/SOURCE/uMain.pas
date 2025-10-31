unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, registry, StdCtrls, Spin, ExtCtrls;

type
  TfmMain = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    cbxCOMPort: TComboBox;
    cbxBaudRate: TComboBox;
    speLogicalNum: TSpinEdit;
    cbxDevice: TComboBox;
    Panel2: TPanel;
    btnCheck: TButton;
    lbSerial: TLabel;
    Label5: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure btnCheckClick(Sender: TObject);
    procedure cbxDeviceChange(Sender: TObject);
    procedure cbxCOMPortChange(Sender: TObject);
  private
    { Private declarations }
  public

  end;
	 function GetSerial(Port,BaudRate,DeviceType,
				LogicalNumber : integer;var SerialNumber : Widestring) : boolean; stdcall; external 'GetSerialNum.dll';
  
var
  fmMain: TfmMain;

function Get_COM_EX  : TStringList;
implementation

{$R *.dfm}

function Get_COM_EX  : TStringList;
var
	ComLst : TStringList;
	max,i : integer;
	tempStr : string;

	procedure EnumerateDosDevices(List: TStrings );
	var
		Buffer: pChar;
		BufLen: Cardinal;
		len: Cardinal;
		p: PChar;
		sl: TStringlist;
	begin
		Assert( Assigned( List ));
		BufLen := High(Word);
		Buffer := AllocMem(BufLen);
		try
			repeat
				len:= QueryDosDevice(nil, Buffer, Buflen - 1);
				if len = ERROR_INSUFFICIENT_BUFFER then
				begin
					BufLen := Buflen * 2;
					ReAllocMem(Buffer, BufLen);
				end;
			until len <> ERROR_INSUFFICIENT_BUFFER;
			Buffer[Len] := #0;
			sl:= TStringlist.Create;
			try
				p:= Buffer;
				while p < @Buffer[Len] do
				begin
					sl.Add(p);
					p:= StrEnd(p)+1;
				end;
				sl.Sorted := true;
				List.Assign(sl);
			finally
				sl.Free;
			end; { finally }
		finally
			FreeMem(Buffer);
		end; { finally }
	end;

	function FillCommList(List : Tstrings ): integer;
	var
		Temp: TStringlist;
		i, index: Integer;
	begin
		try
			Assert(Assigned(List));
			List.Clear;
			Temp := TStringlist.Create;
			try
				EnumerateDosDevices(Temp);
				i:= 1;
				while i<256 do
				begin
                         if Temp.Find('COM'+IntToStr(i), index ) then
						List.Add(Temp[index]);
                         inc(i);
				end;
			finally
				Temp.Free;
			end; { finally }
			Result := List.Count;

		except
			on E:Exception do
				raise Exception.Create('Exception in method "FillCommList":'+E.Message);
		end;

	end;


begin
	ComLst := TStringList.Create;
	Result:= TStringList.Create;
	try
		try
			max := FillCommList(ComLst);
			if max>0 then
			for i:=0 to max-1 do
			begin
				tempStr:= ComLst.Strings[i];
				Delete(tempStr,1,3);
				Result.Add(tempStr);
			end;
		except
               on E:Exception do
				raise Exception.Create('Exception in method "Get_COM_EX":'+E.Message);
          end;
	finally
		ComLst.Free;
	end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
var
	ts :  TStringList;

begin
	btnCheck.Enabled := false;
	//ts := TStringList.Create;
     ts := Get_COM_EX;
	cbxCOMPort.Items := ts;
end;

procedure TfmMain.btnCheckClick(Sender: TObject);
var
	serial : widestring;
begin
	if not GetSerial(strtoint(cbxCOMPort.Text),strtoint(cbxBaudRate.Text),cbxDevice.ItemIndex,speLogicalNum.Value,serial) then
	begin
		ShowMessage('No connection');
		lbSerial.Caption := '';
	end
	else
	begin
		ShowMessage('Successful connection');
		lbSerial.Caption := serial;
	end;
end;

procedure TfmMain.cbxDeviceChange(Sender: TObject);
begin
	if (cbxDevice.ItemIndex = 0) or (cbxDevice.ItemIndex = 29) then
		btnCheck.Enabled := false
	else
		if (cbxCOMPort.Text <> '') and (cbxBaudRate.Text <> '') then
			btnCheck.Enabled := true;
end;

procedure TfmMain.cbxCOMPortChange(Sender: TObject);
begin

	if (cbxDevice.ItemIndex <> 0) and (cbxDevice.ItemIndex <> 28) and (cbxDevice.Text <> '') then
		if (cbxCOMPort.Text <> '') and (cbxBaudRate.Text <> '') then
			btnCheck.Enabled := true
		else
			btnCheck.Enabled := false;
end;

end.
