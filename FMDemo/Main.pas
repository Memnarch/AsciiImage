unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Memo, AsciiImage;

type
  TForm2 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    PaintBox1: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
    procedure Button1Click(Sender: TObject);
  private
    { Private-Deklarationen }
    FImage: TAsciiImage;
  public
    { Public-Deklarationen }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

const
CEllipsis: array[0..4] of string =
  (
    '. . . . .',
    '. 1 . 1 .',
    '. . . . .',
    '. 1 . 1 .',
    '. . . . .'
  );

procedure TForm2.Button1Click(Sender: TObject);
begin
  Memo1.Lines.LoadFromFile('E:\Git\AsciiImage\Demo\Debug\Win32\fixture10.txt');
  FImage.DownSampling := dsX4;
  FImage.LoadFromAscii(Memo1.Lines.ToStringArray);
  FImage.OnDraw := procedure(const AIndex: Integer; var AContext: TAsciiImagePaintContext)
                      begin
                        AContext.FillColor := TAlphaColorRec.Black;
                        AContext.StrokeColor := TAlphaColorRec.Black;
                        if (AIndex <> 1) then
                        begin
                          AContext.FillColor := TAlphaColorRec.White;
                          if AIndex > 1 then
                            AContext.StrokeColor := TAlphaColorRec.White;;
                        end;
                      end;
  PaintBox1.Repaint();
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  FImage := TAsciiImage.Create();
  FImage.DownSampling := dsNone;
end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FImage);
end;

procedure TForm2.PaintBox1Paint(Sender: TObject; Canvas: TCanvas);
begin
//  Canvas.DrawRect(RectF(0, 0, Canvas.Width, Canvas.Height), 1, 1, [TCorner.TopLeft, TCorner.TopRight, TCorner.BottomLeft, TCorner.BottomRight], 1);
//  Canvas.Fill.Color := TAlphaColorRec.Red;
  FImage.Draw(Canvas, Rect(0, 0, Round(PaintBox1.Width), Round(PaintBox1.Height)));
end;

end.
