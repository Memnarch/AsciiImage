program FMDemo;

uses
  FMX.Forms,
  Main in 'Main.pas' {Form2},
  AsciiImage.RenderContext.FM in '..\AsciiImage.RenderContext.FM.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm2, Form2);
  Application.Run;
end.
