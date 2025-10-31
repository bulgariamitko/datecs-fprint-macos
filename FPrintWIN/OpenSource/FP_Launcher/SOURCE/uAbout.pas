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
unit uAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, ExtCtrls, StdCtrls,ShellApi;

type
  TfmAbout = class(TForm)
    lbVer: TLabel;
    Label6: TLabel;
    Label2: TLabel;
    Bevel1: TBevel;
    Label1: TLabel;
    bbtnExit: TBitBtn;
    Button7: TButton;
    procedure FormCreate(Sender: TObject);
    procedure bbtnExitClick(Sender: TObject);
    procedure Button7Click(Sender: TObject);
  private
    { Private declarations }
  public
	function GetVersionInfo(var Build: String): String;
  end;

var
  fmAbout: TfmAbout;

implementation

{$R *.dfm}

function TfmAbout.GetVersionInfo(var Build: String): String;

const
	cDot = '.';
var
	VerInfoSize,
	VerValueSize,
	Dummy          : DWORD;
	VerInfo        : Pointer;
	VerValue       : PVSFixedFileInfo;
	V1, V2, V3, V4 : Word;
begin
	Result := '';
	VerInfoSize := GetFileVersionInfoSize(PChar(ParamStr(0)),Dummy);
	if (VerInfoSize = 0)then
	begin
		Exit;
	end;
	GetMem(VerInfo, VerInfoSize);
	try
		GetFileVersionInfo(PChar(ParamStr(0)), 0, VerInfoSize,VerInfo);
		if VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize) then
		begin
			if (VerValue <> nil) then
			begin
				with VerValue^ do
				begin
					V1 := dwFileVersionMS shr 16;
					V2 := dwFileVersionMS and $FFFF;
					V3 := dwFileVersionLS shr 16;
					V4 := dwFileVersionLS and $FFFF;
				end;
				Build:= IntToStr(V4);
				Result := IntToStr(V1)+ cDot +
				IntToStr(V2)+ cDot +
				IntToStr(V3);//+ cDot +
				//IntToStr(V4);
			end;
		end
	finally
		FreeMem(VerInfo, VerInfoSize);
	end;
end;

procedure TfmAbout.bbtnExitClick(Sender: TObject);
begin
	Close;
end;

procedure TfmAbout.Button7Click(Sender: TObject);
begin
	ShellExecute(fmAbout.Handle,
			'open',
			PChar(ExtractFileDir(Application.ExeName)+'\FPLauncher.pdf'),
			nil,
			PChar(ExtractFileDir(Application.ExeName)),
			SW_NORMAL)
end;

procedure TfmAbout.FormCreate(Sender: TObject);
var
	Build : string;
begin
	lbVer.Caption :=  'Version : '+GetVersionInfo(Build);
	lbVer.Caption := lbVer.Caption +#10#13+'Build : '+Build;
end;

end.
