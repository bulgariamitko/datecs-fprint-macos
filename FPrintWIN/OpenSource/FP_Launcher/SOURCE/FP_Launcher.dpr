program FP_Launcher;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain},
  uAbout in 'uAbout.pas' {fmAbout};

{$R *.res}

begin
  Application.Initialize;
  Application.HelpFile := 'H:\SOFT_SVN\EXAMPLES\PROGRAMS\FP_Launcher\DOC\FPLauncher_Readme.pdf';
  Application.Title := 'FPrint launcher';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
