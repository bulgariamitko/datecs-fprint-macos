{
Copyright (c) 2007 Datecs Ltd.

TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

1.You may copy, modify and distribute copies of all or part of the program's
source code as you received it. In any case of using this or part of this
source code you must make a reference to Datecs Ltd. as an original provider
of this source.

2.You may copy, modify and distribute copies of the Program and the source
code for public and comercial purposes only if it's used along with devices
and hardware, sold by Datecs Ltd. or any Datecs Ltd. resellers.
(This part of the licence does not apply for md5.pas)

3.In case you modify the Program's source and redistribute it, you must
explicitly mention about the modification in your distribution's license
agreement and notify Datecs Ltd.
(for contacts - cvetanov@datecs.bg, dobrin@datecs.bg)

This is a free software with some limitations and no warranties.
This software has been released to the public. Use at your own risk!

}
unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ComCtrls, Registry, ShellApi, md5, FileCtrl,
  AppEvnts;

type
  TfmMain = class(TForm)
    sBar: TStatusBar;
    Panel1: TPanel;
    rgMode: TRadioGroup;
    cbxOperation: TComboBox;
    Label1: TLabel;
    Panel2: TPanel;
    Panel3: TPanel;
    Label5: TLabel;
    edCopyFolder: TEdit;
    bExecFolder: TButton;
    Label4: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label6: TLabel;
    edSerialNumber: TEdit;
    edPar3: TEdit;
    cbbxPort: TComboBox;
    cbbxSpeed: TComboBox;
    bFiletoPrint: TButton;
    Label8: TLabel;
    edFile: TEdit;
    bFileToCopy: TButton;
    MemoCmdLine: TMemo;
    MemoResident: TMemo;
    btnRun: TButton;
    edPath: TEdit;
    bFprint: TButton;
    Label9: TLabel;
    odlgAnswerFile: TOpenDialog;
    odlgFPrintExe: TOpenDialog;
    odlgFileToCopy: TOpenDialog;
    Label10: TLabel;
    edAnswer: TEdit;
    bAnswerFolder: TButton;
    lbAnswerFileName: TLabel;
    edAnswerFileName: TEdit;
    cbxAnswer: TComboBox;
    Label11: TLabel;
    chkAnswer: TCheckBox;
    lbAnswrFile: TLabel;
    edAnswFileName: TEdit;
    cbxSamples: TComboBox;
    Label7: TLabel;
    Panel4: TPanel;
    Label12: TLabel;
    Panel5: TPanel;
    Label13: TLabel;
    bAnswerfile: TButton;
    odlgFileToPrint: TOpenDialog;
    btnAbout: TButton;
    ApplicationEvents1: TApplicationEvents;
    chbxRepeatCopy: TCheckBox;
    edRepeatCount: TEdit;
    tmrRepeatCopy: TTimer;
    procedure FormActivate(Sender: TObject);
    procedure rgModeClick(Sender: TObject);
    procedure btnRunClick(Sender: TObject);
    procedure cbxOperationChange(Sender: TObject);
    procedure bFiletoPrintClick(Sender: TObject);
    procedure bFprintClick(Sender: TObject);
    procedure bExecFolderClick(Sender: TObject);
    procedure bFileToCopyClick(Sender: TObject);
    procedure bAnswerFolderClick(Sender: TObject);
    procedure cbxAnswerChange(Sender: TObject);
    procedure chkAnswerClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure cbxSamplesChange(Sender: TObject);
    procedure bAnswerfileClick(Sender: TObject);
    procedure btnAboutClick(Sender: TObject);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure edRepeatCountChange(Sender: TObject);
    procedure tmrRepeatCopyTimer(Sender: TObject);
  private
    FStop_flag: boolean;
    procedure SetStop_flag(const Value: boolean);
    { Private declarations }
  public
	APP_FOLDER : String;
	Settings_ : TStringList;
     Execute_folder : string;
     Answer_folder : string;
    procedure LogException2(E:string);

    property Stop_flag : boolean read FStop_flag write SetStop_flag;
  end;

function chopField_ex(const Delimiter : Char; const F: Byte; const Source: String): String;

var
  fmMain: TfmMain;

implementation
  uses uAbout;
{$R *.dfm}

function chopField_ex(const Delimiter : Char; const F: Byte; const Source: String): String;
var
     B : integer;
	Flag: Byte;
	S: String;
begin
	B:= 0;
	Flag:= 0;
	S:= '';

	while (B < length(Source)) and (F<>0) do
	begin
		Inc(B);
		if (Source[B] = Delimiter) then Inc(Flag);
		if Flag = F then break;
	end;

	while B < length(Source) do
	begin
		inc(B);
		if (Source[B] = Delimiter) then break;
		S:= S + Source[B];
	end;
	RESULT:= S;
end;

procedure TfmMain.FormActivate(Sender: TObject);
var
	ComLst,ResltList : TStringList;
	max,i : integer;
	tempStr : string;
     VerInfo: TOSVersioninfo;

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
          Result :=0;
		try
			Assert(Assigned(List));
			List.Clear;
			Temp := TStringlist.Create;
			try
				EnumerateDosDevices(Temp);
				i:= 1;
				while i<256 do
				begin
                         if (Temp.Find('COM'+IntToStr(i), index )) then
     					List.Add(Temp[index]);
                         inc(i);
				end;
			finally
				Temp.Free;
			end; { finally }
			Result := List.Count;

		except
			on E:Exception do
				LogException2('Exception in method "FillCommList":'+E.Message);
		end;

	end;

      function Get_WIN98_serial(List : Tstrings) : boolean;
      var
          i : integer;
          portStr : string;
          portHND : THandle;
      begin
          Assert(Assigned(List));
          List.Clear;
          Result:=false;
          try
                for i:= 1 to 256 do
                begin
                    portStr := format('\\.\COM%d',[i]);
                    portHND := CreateFile(pAnsiChar(portStr), GENERIC_READ or GENERIC_WRITE, 0, nil, OPEN_EXISTING, 0, 0);
                    if portHND = INVALID_HANDLE_VALUE then
                    begin
                         //Error := GetLastError;
                         //if (Error = ERROR_ACCESS_DENIED) or (Error = ERROR_ACCESS_DENIED)  then
                              //Result:=1;
                         CloseHandle(portHND);
                    end
                    else
                    begin
                         Result:=true;
                         CloseHandle(portHND);
                         List.Add(inttostr(i));
                    end;
                end;

          except
               on E:Exception do
				LogException2('Exception in method "Get_WIN98_serial":'+E.Message);
          end;

      end;
begin
     ComLst := TStringList.Create;
	ResltList:= TStringList.Create;
	try
		try

               VerInfo.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
               GetVersionEx(VerInfo);
               if (VerInfo.dwPlatformId <> VER_PLATFORM_WIN32_NT) then
                    Get_WIN98_serial(ResltList);


               if (VerInfo.dwPlatformId = VER_PLATFORM_WIN32_NT) then
               begin
		     	max := FillCommList(ComLst);
		     	if max>0 then
		     	for i:=0 to max-1 do
			     begin
			     	tempStr:= ComLst.Strings[i];
			     	Delete(tempStr,1,3);
			     	ResltList.Add(tempStr);
			     end;
               end;
		except
               on E:Exception do
				LogException2('Exception in method "Get_COM_EX":'+E.Message);
          end;
	finally
          cbbxPort.Clear;
          cbbxPort.Items := ResltList;
          ResltList.Free;
		ComLst.Free;
	end;
end;

procedure TfmMain.rgModeClick(Sender: TObject);
begin
	if rgMode.ItemIndex = 0 then
	begin
		panel3.Enabled:=false;
		cbxOperation.Items.Clear;
		cbxOperation.Items.Add('Start with command line');
		cbxOperation.ItemIndex:=0;
		cbxOperation.DropDownCount :=1;
	end;
	if rgMode.ItemIndex = 1 then
	begin
		panel3.Enabled:=true;
          cbxOperation.Items.Clear;
		cbxOperation.Items.Add('Start with command line');
		cbxOperation.Items.Add('Copy file to folder');
		cbxOperation.ItemIndex:=0;
		cbxOperation.DropDownCount :=2;
	end;
end;

procedure TfmMain.btnRunClick(Sender: TObject);
var
	cmdLine : string;
	ps_info: TProcessInformation;
	st_info : TStartupInfo;
	Fin : boolean;
	oldhash,
	hash			:	MD5Digest;
	i,
	counter,
	AnswerFilesCount : integer;
	Fname : string;
     port, speed : string;


	procedure CmdOperation;//(Mode : integer);
	begin
		begin
			if edPath.Text = '' then
			begin
				cmdLine := ExtractFileDir(application.ExeName)+'\FPrint.exe';
				if not FileExists(cmdLine) then
				begin
					edPath.SetFocus;
					sBar.Panels[1].Text := 'FPrint not found, please select its location';
					exit;
				end else edPath.Text := cmdLine;

			end;

			if edSerialNumber.Text <> '' then
			begin
				if (edPar3.Text = '') then
				begin
					edpar3.SetFocus;
					sBar.Panels[1].Text := 'Please enter file name';
					exit;
				end
				else
				if (cbbxSpeed.Text = '') then
				begin
					cbbxSpeed.SetFocus;
					sBar.Panels[1].Text := 'Please enter baud rate';
					exit;
				end;
                    if (cbbxPort.Text = '') then
				begin
					cbbxPort.SetFocus;
					sBar.Panels[1].Text := 'Please enter COM port number';
					exit;
				end;


				cmdLine := trim('COM'+cbbxPort.Text+'" "'+
							cbbxSpeed.Text+'" "'+
							edPar3.Text+'" "'+
							edSerialNumber.Text);
                    cmdLine :=    '"'+cmdLine+'"';
				try
					FillChar(st_info,SizeOf(TStartupInfo),#0);
					FillChar(ps_info,SizeOf(TProcessInformation),#0);
					st_info.cb := sizeof(STARTUPINFO);
					if not CreateProcess(
							{PChar(edPath.text)}nil,
							PChar(edPath.text+' '+cmdLine),
							Nil,
							Nil,
							False,
							0,
							Nil,
							PChar(ExtractFileDir(edPath.text)),
							st_info,
							ps_info) then
					begin
						sBar.Panels[1].Text := 'Error creating process';
						exit;
					end
					else
					begin
						sBar.Panels[1].Text := 'Printing...';
						WaitForSingleObject(ps_info.hProcess, INFINITE);

						if edAnswFileName.Text <> '' then
						begin
							MemoCmdLine.Clear;
							MemoCmdLine.Lines.LoadFromFile(edAnswFileName.Text);
						end;
						sBar.Panels[1].Text := 'Print finished';
					end;
				finally
					CloseHandle(ps_info.hProcess);
					CloseHandle(ps_info.hThread);
				end;
			end
			else
			begin
                    if cbbxPort.Text='' then port:=''
				else port := '"COM'+cbbxPort.Text+'" ';
				if cbbxSpeed.Text='' then speed:=''
				else speed:= '"'+cbbxSpeed.Text+'" ';//"COM2" "115200" "C:\F.inp"

				cmdLine := trim(port+speed+'"'+
							edPar3.Text+'"');

				try
					FillChar(st_info,SizeOf(TStartupInfo),#0);
					FillChar(ps_info,SizeOf(TProcessInformation),#0);
					st_info.cb := sizeof(STARTUPINFO);
					if not CreateProcess(
							{PChar(edPath.text)}nil,
							PChar(edPath.text+' '+cmdLine),
							Nil,
							Nil,
							False,
							0,
							Nil,
							PChar(ExtractFileDir(edPath.text)),
							st_info,
							ps_info) then
					begin
						sBar.Panels[1].Text := 'Error creating process';
						exit;
					end
					else
					begin
						sBar.Panels[1].Text := 'Printing...';
						WaitForSingleObject(ps_info.hProcess, INFINITE);
						if edAnswFileName.Text <> '' then
						begin
							MemoCmdLine.Clear;
							MemoCmdLine.Lines.LoadFromFile(edAnswFileName.Text);
						end;
						sBar.Panels[1].Text := 'Print finished';
					end;
				finally
					CloseHandle(ps_info.hProcess);
					CloseHandle(ps_info.hThread);
				end;
			end;

		end;

	end;


	function FindAnswerFile(var Name : string;Var Count : integer) : boolean;
	var
		FileList : TStringList;
		FileData : TWIN32FindData;
		Handle : THandle;
		LastFound : boolean;
	begin

			FileList := Tstringlist.Create;
			Result:=False;
			try

				if (edAnswer.Text <> '') then
				try
					Count:=0;
					Handle := FindFirstFile(PChar(edAnswer.Text+'\*.txt'),FileData);
					if Handle <> INVALID_HANDLE_VALUE then
					begin
						repeat
							Name := FileData.cFileName;
							if pos('200',Name)>0 then
							begin
								FileList.append(Fname);
								inc(Count);
							end;
							LastFound := FindNextFile(Handle,FileData);
							Application.ProcessMessages;
						until not LastFound;
						if FileList.Count > 0 then
							Name := FileList[FileList.Count-1];
					end else	exit;
					Result:=True;
				except
					on E:Exception do
						LogException2('Exception in method: "FindAnswerFile"'+E.Message);
				end;
			finally
				FileList.Free;
			end;
	end;

	function ResidentPrint : boolean;
	var
		newname : string;
	begin
		Result:=False;
		if (edCopyFolder.Text <> '') and
			(edFile.Text <> '') and (edAnswer.Text <> '') then
			try
				newname := edCopyFolder.Text+'\sell_execute.txt';

                    if chbxRepeatCopy.Checked and (strtoint(trim(edRepeatCount.Text)) > 0) then
                         tmrRepeatCopy.Enabled:= true
                    else
				if not CopyFile(Pchar(edFile.Text),Pchar(newname),false) then
				begin
					sBar.Panels[1].Text:= 'Cannot copy file';
					exit;
				end;
				sBar.Panels[1].Text:= 'Printing...';
				Result:=True;
			except
				on E:Exception do
					LogException2('Exception in method: "Button1Click"'+E.Message);
			end;
	end;

	procedure ResidentConstantName;
	var
		i : integer;
	begin
		if edCopyFolder.Text = '' then
		begin
			edCopyFolder.SetFocus;
			sBar.Panels[1].Text := 'Please select executable folder';
			exit;
		end;
		if edFile.Text = '' then
		begin
			edFile.SetFocus;
			sBar.Panels[1].Text := 'Please select file to print';
			exit;
		end;
		if edAnswer.Text = '' then
		begin
			edAnswer.SetFocus;
			sBar.Panels[1].Text := 'Please select answer folder';
			exit;
		end;

		if edAnswerFileName.Text = '' then
		begin
			if FileExists(edAnswer.Text+'\sell_execute.txt') then
				oldhash := md5file(edAnswer.Text+'\sell_execute.txt')
			else
			for i:=0 to 15 do
				oldhash[i] := 0;
		end
		else
		begin
			if FileExists(edAnswer.Text+'\'+edAnswerFileName.Text) then
				oldhash := md5file(edAnswer.Text+'\'+edAnswerFileName.Text)
			else
			for i:=0 to 15 do
				oldhash[i] := 0;
		end;

		if not ResidentPrint then Exit;
          if tmrRepeatCopy.Enabled then Exit;

		if FileExists(edCopyFolder.Text+'\sell_execute.txt') then
		begin
			counter:=0;
			repeat
				sleep(100);
				inc(counter);
				Application.ProcessMessages;
			until (not FileExists(edCopyFolder.Text+'\sell_execute.txt')) or (counter=100);
		end;
		counter:=0;
		Fin:=False;
		repeat
			if edAnswerFileName.Text = '' then
			begin
				if FileExists(edAnswer.Text+'\sell_execute.txt') then
					hash := md5file(edAnswer.Text+'\sell_execute.txt')
				else
					for i:=0 to 15 do
						hash[i] := 0;
			end
			else
			begin
				if FileExists(edAnswer.Text+'\'+edAnswerFileName.Text) then
					hash := md5file(edAnswer.Text+'\'+edAnswerFileName.Text)
				else
                    	for i:=0 to 15 do
						hash[i] := 0;
			end;
			for i:= 0 to 15 do
			begin
				if hash[i] <> oldHash[i] then
				begin
					Fin:=true;
					break;
				end;
			end;
			inc(counter);
			sleep(1000);
			Application.ProcessMessages;
		until (Fin) or (counter = 150);
		sBar.Panels[1].Text := 'Printing finished';

		MemoResident.Clear;
		if edAnswerFileName.Text = '' then
		begin
			if FileExists(edAnswer.Text+'\sell_execute.txt') then
				MemoResident.Lines.LoadFromFile(edAnswer.Text+'\sell_execute.txt')
			else sBar.Panels[1].Text := 'Answer file not found';
		end
		else
			if FileExists(edAnswer.Text+'\'+edAnswerFileName.Text) then
				MemoResident.Lines.LoadFromFile(edAnswer.Text+'\'+edAnswerFileName.Text)
			else sBar.Panels[1].Text := 'Answer file not found';

	end;

	procedure ResidentDateTimeName;
	begin
		FindAnswerFile(Fname,AnswerFilesCount);

		if not ResidentPrint then Exit;
		if FileExists(edCopyFolder.Text+'\sell_execute.txt') then
		begin
			counter:=0;
			repeat
				sleep(100);
				inc(counter);
				Application.ProcessMessages;
			until (not FileExists(edCopyFolder.Text+'\sell_execute.txt')) or (counter=100);
		end;
		i:= AnswerFilesCount;
		counter:= 0;
		repeat
			sleep(100);
			FindAnswerFile(Fname,AnswerFilesCount);
			inc(counter);
			Application.ProcessMessages;
		until (AnswerFilesCount > i) or (counter = 100);
		sBar.Panels[1].Text := 'Printing finished';
		MemoResident.Clear;
		if FileExists(edanswer.Text+'\'+Fname) then
			MemoResident.Lines.LoadFromFile(edanswer.Text+'\'+Fname)
		else	sBar.Panels[1].Text := 'Answer file not found';

	end;

begin
	try
          Stop_flag:= false;

		sBar.Panels[1].Text := '';
		case cbxOperation.ItemIndex of
			0	:
				 CmdOperation;//(rgMode.ItemIndex);
			1	:
               begin
                    if btnRun.Caption = 'Stop' then
                    begin
                         Stop_flag:= true;
                         Exit;
                    end;
				case cbxAnswer.ItemIndex of
					0	:	ResidentConstantName;

					1	:   	ResidentDateTimeName;

				end;
               end;
		end;
	except
		on E:Exception do
			LogException2('Exception in method: "btnRunClick"'+E.Message);
	end;

end;

procedure TfmMain.cbxOperationChange(Sender: TObject);
begin
	case cbxOperation.ItemIndex of
		1	:  	edCopyFolder.SetFocus;
		0	:    cbbxPort.SetFocus;
	end;
end;

procedure TfmMain.bFiletoPrintClick(Sender: TObject);
begin
	try
          try
               odlgFileToPrint.InitialDir := Settings_[3];
		     if odlgFileToPrint.Execute then
		     begin
			     edPar3.Text:=odlgFileToPrint.FileName;
		    	     Settings_.Strings[3]:= ExtractFilePath(odlgFileToPrint.FileName);
		     end;
          except
               on E:Exception do
                    LogException2('Exception in method "bFiletoPrint":'+E.Message);
          end;
	finally
		Settings_.SaveToFile(APP_FOLDER+'FPL_Settings.txt');
	end;
end;

procedure TfmMain.bFprintClick(Sender: TObject);
begin
     try
          try
               odlgFPrintExe.InitialDir:=Settings_[1];
               if odlgFPrintExe.Execute then
               begin
          		edPath.Text:=odlgFPrintExe.FileName;
                    Settings_[1] := ExtractFilePath(odlgFPrintExe.FileName);
               end;
          except
               on E:Exception do
                    LogException2('Exception in method "bFprintClick":'+E.Message);
          end;
     finally
          Settings_.SaveToFile(APP_FOLDER+'FPL_Settings.txt');
     end;
end;

procedure TfmMain.bExecFolderClick(Sender: TObject);
begin
     try
          try
               Execute_folder := Settings_[7];
               if SelectDirectory('Browse for folder',WideString('MyComputer'),Execute_folder) then
               begin
		          edCopyfolder.Text := Execute_folder;
                    Settings_.Strings[7]:= Execute_folder;
               end;
          except
               on E:Exception do
                    LogException2('Exception in method "bExecFolderClick":'+E.Message);
          end;
     finally
          Settings_.SaveToFile(APP_FOLDER+'FPL_Settings.txt');
     end;

end;

procedure TfmMain.bFileToCopyClick(Sender: TObject);
begin
     try
          try
               odlgFileToCopy.InitialDir := Settings_[9];
               if odlgFileToCopy.Execute then
               begin
	          	edFile.Text:=odlgFileToCopy.FileName;
                    Settings_.Strings[9]:= ExtractFilePath(odlgFileToCopy.FileName);
               end;
          except
               on E:Exception do
                    LogException2('Exception in method "bFileToCopyClick":'+E.Message);
          end;
     finally
          Settings_.SaveToFile(APP_FOLDER+'FPL_Settings.txt');
     end;

end;

procedure TfmMain.bAnswerFolderClick(Sender: TObject);
begin
     try
          try
               Answer_folder := Settings_[11];
               if SelectDirectory('Browse for folder',WideString('MyComputer'),Answer_folder) then
               begin
	          	edAnswer.Text := Answer_folder;
                    Settings_.Strings[11]:= Answer_folder;
               end;
          except
               on E:Exception do
                    LogException2('Exception in method "bFileToCopyClick":'+E.Message);
          end;
     finally
          Settings_.SaveToFile(APP_FOLDER+'FPL_Settings.txt');
     end;
end;

procedure TfmMain.cbxAnswerChange(Sender: TObject);
begin
	if cbxAnswer.ItemIndex=1 then
	begin
		lbAnswerFileName.Enabled:=False;
		edAnswerFileName.Enabled:=False;
	end;
	if cbxAnswer.ItemIndex=0 then
	begin
		lbAnswerFileName.Enabled:=True;
		edAnswerFileName.Enabled:=True;
	end;
end;

procedure TfmMain.chkAnswerClick(Sender: TObject);
begin
	if chkAnswer.Checked then edAnswFileName.Text:=edPar3.Text;
	lbAnswrFile.Enabled := not   chkAnswer.Checked;
	edAnswFileName.Enabled := not  chkAnswer.Checked;
end;

procedure TfmMain.FormCreate(Sender: TObject);
var

	FileData : TWIN32FindData;
	Handle : THandle;
	LastFound : boolean;
	sampleDir,
	Name : string;
begin
	try
		Settings_ := TStringList.Create;
		APP_FOLDER:=ExtractFilePath(Application.ExeName);
		if FileExists(APP_FOLDER+'FPL_Settings.txt') then
			Settings_.LoadFromFile(APP_FOLDER+'FPL_Settings.txt')
          else
          begin
               Settings_.Add('Path to FPrint.exe:');
               Settings_.Add(APP_FOLDER);   //1
               Settings_.Add('Path to file(for print) name:');
               Settings_.Add(APP_FOLDER);   //3
               Settings_.Add('Path to answer file:');
               Settings_.Add(APP_FOLDER);   //5
               Settings_.Add('Execute dir:');
               Settings_.Add(APP_FOLDER);   //7
               Settings_.Add('Path to file(for copy) name:');
               Settings_.Add(APP_FOLDER);   //9
               Settings_.Add('Answer dir:');
               Settings_.Add(APP_FOLDER);   //11
               Settings_.SaveToFile(APP_FOLDER+'FPL_Settings.txt')
          end;

          edCopyFolder.Text := Settings_[7];
          edAnswer.Text:= Settings_[11];

		sampleDir := ExtractFileDir(Application.ExeName)+'\Samples';
		if DirectoryExists(sampleDir) then
		begin
			Handle := FindFirstFile(PChar(sampleDir+'\*.txt'),FileData);
			if Handle <> INVALID_HANDLE_VALUE then
			begin
				cbxSamples.Items.Add('');
				repeat
					Name := FileData.cFileName;
					cbxSamples.Items.Add(Name);
					LastFound := FindNextFile(Handle,FileData);
					Application.ProcessMessages;
				until not LastFound;
			end else exit;
		end;
	except
		on E:Exception do
			LogException2('Exception in method: "FormCreate"'+E.Message);
	end;

end;

procedure TfmMain.cbxSamplesChange(Sender: TObject);
begin
	if cbxSamples.ItemIndex>0 then
		case cbxOperation.ItemIndex of
			0	:
					edPar3.Text := ExtractFileDir(Application.ExeName)+
								'\Samples\'+ cbxSamples.Text;
			1	:    edFile.Text := ExtractFileDir(Application.ExeName)+
								'\Samples\'+ cbxSamples.Text;
		end;
end;

procedure TfmMain.bAnswerfileClick(Sender: TObject);
begin
     try
          try
               odlgAnswerFile.InitialDir := Settings_[5];
               if odlgAnswerFile.Execute then
               begin
		          edAnswFileName.Text:=odlgAnswerFile.FileName;
                    Settings_.Strings[5]:= ExtractFilePath(odlgAnswerFile.FileName);
               end;
          except
               on E:Exception do
                   LogException2('Exception in method "TfmMain.bAnswerfileClick":'+E.Message);
          end;
     finally
          Settings_.SaveToFile(APP_FOLDER+'FPL_Settings.txt');
     end;

end;

procedure TfmMain.btnAboutClick(Sender: TObject);
begin

	fmAbout := TfmAbout.Create(fmMain);
	try
		fmAbout.ShowModal;
     finally
     	fmAbout.Free;
     end;
end;

procedure TfmMain.LogException2(E: string);
var
	tmpFilename: string;
	LogFile: TextFile;
begin
	tmpFilename := ChangeFileExt (Application.Exename,'_log.txt');
	AssignFile (LogFile,tmpFilename);
	if FileExists (tmpFileName) then
		Append (LogFile)
	else
		Rewrite (LogFile);
	Writeln (LogFile, DateTimeToStr (Now) + ':' + E);
	CloseFile (LogFile);
end;

procedure TfmMain.ApplicationEvents1Exception(Sender: TObject;
  E: Exception);
begin
     LogException2(E.Message);
end;


procedure TfmMain.edRepeatCountChange(Sender: TObject);
begin
     try
          strtoint(trim(edRepeatCount.Text));
     except
          on E:Exception do
          begin
               ShowMessage('Enter numbers only');
               edRepeatCount.Text:='0';
          end;
     end;
end;

procedure TfmMain.tmrRepeatCopyTimer(Sender: TObject);
var
     ErrFound,Fin: boolean;
     counter : integer;
     newname : string;

     function SearchAnswer : boolean;
     var
          tmp_str : string;
          errList : TStringList;
          i : integer;
     begin
          Result:= false;
          errList:= TStringList.Create;
          try
               try
                    if edAnswerFileName.Text = '' then
		     		errList.LoadFromFile(edAnswer.Text+'\sell_execute.txt')
	     		else errList.LoadFromFile(edAnswer.Text+'\'+edAnswerFileName.Text);
                    for i := 0 to errList.Count-1 do
                    begin
                         tmp_str:= chopField_ex(';',0,errList[i]);
                         tmp_str:= chopField_ex(',',4,tmp_str);
                         if strtoint(trim(tmp_str)) > 0 then
                              Result:= true;
                    end;
               except
                    on E:Exception do
                         raise Exception.Create('Exception in method "SearchAnswer":'+E.Message);
               end;
          finally
               errList.Clear;
               FreeAndNil(errList);
          end;
     end;

begin
     tmrRepeatCopy.Enabled:= false;
     ErrFound:= false;
     try
          try
               if FileExists(edAnswer.Text+'\sell_execute.txt') then
                    DeleteFile(edAnswer.Text+'\sell_execute.txt');
               if FileExists(edAnswer.Text+'\'+edAnswerFileName.Text) then
                    DeleteFile(edAnswer.Text+edAnswerFileName.Text);
               if FileExists(edCopyFolder.Text+'\3x3cut3.txt') then
                    DeleteFile(edCopyFolder.Text+'\3x3cut3.txt');

               btnRun.Caption:= 'Stop';
               newname := edCopyFolder.Text+'\sell_execute.txt';
               if not FileExists(newname) then
                    CopyFile(Pchar(edFile.Text),Pchar(newname),true)
               else exit;
               edRepeatCount.Text:= inttostr(strtoint(trim(edRepeatCount.Text)) - 1);
               fin:= false;
               counter:= 1;
               repeat
     			if edAnswerFileName.Text = '' then
	     		begin
		     		if FileExists(edAnswer.Text+'\sell_execute.txt') then
                              Fin:= True;
     			end
	     		else
			     	if FileExists(edAnswer.Text+'\'+edAnswerFileName.Text) then
                              Fin:= True;
     			inc(counter);
	     		sleep(1000);
		     	Application.ProcessMessages;
     		until (Fin) or (counter = 150);

               ErrFound:= SearchAnswer;

               MemoResident.Clear;
		     if edAnswerFileName.Text = '' then
     		begin
	     		if FileExists(edAnswer.Text+'\sell_execute.txt') then
		     		MemoResident.Lines.LoadFromFile(edAnswer.Text+'\sell_execute.txt')
			     else sBar.Panels[1].Text := 'Answer file not found';

                    DeleteFile(edAnswer.Text+'\sell_execute.txt');
     		end
	     	else
               begin
		     	if FileExists(edAnswer.Text+'\'+edAnswerFileName.Text) then
			     	MemoResident.Lines.LoadFromFile(edAnswer.Text+'\'+edAnswerFileName.Text)
     			else sBar.Panels[1].Text := 'Answer file not found';

                    DeleteFile(edAnswer.Text+edAnswerFileName.Text);
               end;

          except
               on E:Exception do
                    raise Exception.Create('Exception in method "tmrRepeatCopyTimer":'+E.Message);
          end;
     finally
          sBar.Panels[1].Text := 'Printing finished';
          if (strtoint(trim(edRepeatCount.Text)) > 0) and (not Stop_flag) and (not ErrFound) then
               tmrRepeatCopy.Enabled:= true
          else btnRun.Caption:= 'Run';

          if ErrFound then
          begin
               btnRun.Caption:= 'Run';
               ShowMessage('Found errors, see the memo!');
          end
          else btnRun.Caption:= 'Run';
     end;
end;

procedure TfmMain.SetStop_flag(const Value: boolean);
begin
     FStop_flag := Value;
end;

end.
