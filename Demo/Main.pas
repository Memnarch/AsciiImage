unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, AsciiImage;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Memo1: TMemo;
    cbGrid: TCheckBox;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

uses
  AsciiImage.RenderContext.Intf,
  AsciiImage.RenderContext.GDI,
  AsciiImage.RenderContext.Types;

{$R *.dfm}

const
  CDot: array[0..4] of string =
  (
    '. . . . .',
    '. . . . .',
    '. . 1 . .',
    '. . . . .',
    '. . . . .'
  );

  CLine: array[0..4] of string =
  (
    '. . . . .',
    '. . 2 . .',
    '. 1 . 1 .',
    '. . 2 . .',
    '. . . . .'
  );

  CLineB: array[0..4] of string =
  (
    '1 . . . 2',
    '. . . . .',
    '. . . . .',
    '. . . . .',
    '2 . . . 1'
  );

  CEllipsis: array[0..4] of string =
  (
    '. . . . .',
    '. 1 . 1 .',
    '. . . . .',
    '. 1 . 1 .',
    '. . . . .'
  );

  CPath: array[0..4] of string =
  (
    '. . . . .',
    '. 1 . 2 .',
    '. 6 5 . .',
    '. . 4 3 .',
    '. . . . .'
  );

  CPathB: array[0..4] of string =
  (
    '. . . . .',
    '. . . 2 .',
    '. . . . .',
    '. . . 3 .',
    '. . . . .'
  );

procedure TForm1.Button1Click(Sender: TObject);
var
  LImage: TAsciiImage;
begin
  Image1.Picture.Bitmap.SetSize(Image1.Width, Image1.Height);
  LImage := TAsciiImage.Create();
  try
    Memo1.Lines.LoadFromFile('Fixture10.txt');
    LImage.LoadFromAscii(Memo1.Lines.ToStringArray);
    LImage.OnDraw :=  procedure(const AIndex: Integer; var AContext: TAsciiImagePaintContext)
                      begin
                        AContext.FillColor := clBlack;
                        AContext.StrokeColor := clBlack;
                        if (AIndex <> 1) then
                        begin
                          AContext.FillColor := clWhite;
                          if AIndex > 1 then
                            AContext.StrokeColor := clWhite;
                        end;
                      end;
    Image1.Picture.Bitmap.Canvas.StretchDraw(Image1.Picture.Bitmap.Canvas.ClipRect, LImage);
    if cbGrid.Checked then
      LImage.DrawDebugGrid(Image1.Picture.Bitmap.Canvas);

  finally
    LImage.Free;
  end;
end;

end.
