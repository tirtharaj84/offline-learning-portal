"""Build three illustrated PDF guides from docs/guide_sources/guides.json.
Requires ReportLab. Font files can be supplied using --font-dir; otherwise
uses DejaVu fonts on Linux or Arial/Consolas in C:\\Windows\\Fonts on Windows.
Markdown companions are editable exports; rebuild from JSON to change PDFs.
"""
from pathlib import Path
import argparse,json,html,textwrap,os
from reportlab.pdfgen import canvas
from reportlab.platypus import SimpleDocTemplate,Paragraph,Spacer,PageBreak,Table,TableStyle,Preformatted,KeepTogether
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib import colors
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.graphics.shapes import Drawing,Rect,Line,String,Polygon
ROOT=Path(__file__).resolve().parents[1]
NAVY=colors.HexColor('#193b57');TEAL=colors.HexColor('#16776b');INK=colors.HexColor('#253e51');LIGHT=colors.HexColor('#edf5f6')
def fonts(custom=None):
 if custom:
  folder=Path(custom);names=['DejaVuSans.ttf','DejaVuSans-Bold.ttf','DejaVuSansMono.ttf']
 elif os.name=='nt':
  folder=Path(os.environ.get('WINDIR',r'C:\Windows'))/'Fonts';names=['arial.ttf','arialbd.ttf','consola.ttf']
 else:
  folder=Path('/usr/share/fonts/truetype/dejavu');names=['DejaVuSans.ttf','DejaVuSans-Bold.ttf','DejaVuSansMono.ttf']
 for label,name in zip(['Guide','GuideBold','GuideMono'],names):pdfmetrics.registerFont(TTFont(label,str(folder/name)))
def diagram(kind):
 d=Drawing(499,150)
 def box(x,y,w,h,title,detail):
  d.add(Rect(x,y,w,h,rx=7,ry=7,fillColor=LIGHT,strokeColor=TEAL,strokeWidth=1))
  d.add(String(x+w/2,y+h-20,title,fontName='GuideBold',fontSize=10,fillColor=NAVY,textAnchor='middle'))
  d.add(String(x+w/2,y+14,detail,fontName='Guide',fontSize=8,fillColor=INK,textAnchor='middle'))
 def arrow(x1,y1,x2,y2):
  d.add(Line(x1,y1,x2,y2,strokeColor=TEAL,strokeWidth=1.5))
  if x2>x1:d.add(Polygon([x2,y2,x2-6,y2+3,x2-6,y2-3],fillColor=TEAL,strokeColor=TEAL))
  else:d.add(Polygon([x2,y2,x2-3,y2+6,x2+3,y2+6],fillColor=TEAL,strokeColor=TEAL))
 if kind=='network':
  box(0,75,145,62,'Windows server','NGINX + local resources');box(183,75,130,62,'School network','LAN / Wi-Fi');box(355,90,144,47,'Learner device','Server IP in browser');box(355,15,144,47,'ICT focal person','Adds permitted resources')
  arrow(145,106,183,106);arrow(313,106,355,113);arrow(313,90,355,40);d.add(String(5,25,'Internet is for obtaining resources; complete local files stay on the LAN.',fontName='Guide',fontSize=8,fillColor=INK))
 elif kind=='workflow':
  box(0,82,150,55,'Permitted resource','PDF / audio / video');box(185,82,135,55,'Live resources','Optional metadata');box(350,82,149,55,'Rebuild catalogue','Python on server');box(185,8,135,55,'Learner browser','Search and open');box(350,8,149,55,'Verify locally','Then on another device');arrow(150,110,185,110);arrow(320,110,350,110);arrow(425,82,425,63);arrow(350,35,320,35)
 elif kind=='html':
  box(0,80,160,57,'Catalogue card','Registered entry HTML');box(205,80,135,57,'Entry page','index.html');box(375,80,124,57,'Local assets','CSS / JS / images');box(205,8,135,57,'Local viewer','Media / 3D');box(375,8,124,57,'Data and models','Decoder files too');arrow(160,108,205,108);arrow(340,108,375,108);arrow(272,80,272,65);arrow(340,36,375,36)
 elif kind=='kiwix':
  box(0,50,132,62,'Learner browser','School server IP');box(177,89,145,52,'Portal service','NGINX :80');box(177,9,145,52,'Kiwix service','kiwix-serve :8081');box(362,89,137,52,'Local resources','PDF / media / HTML');box(362,9,137,52,'ZIM archives','Independent folder');arrow(132,96,177,115);arrow(132,67,177,35);arrow(322,115,362,115);arrow(322,35,362,35)
 return d
class NumberedCanvas(canvas.Canvas):
 def __init__(self,*a,**kw):super().__init__(*a,**kw);self.states=[]
 def showPage(self):self.states.append(dict(self.__dict__));self._startPage()
 def save(self):
  total=len(self.states)
  for state in self.states:
   self.__dict__.update(state);self.setStrokeColor(colors.HexColor('#cbd9df'));self.line(48,43,547,43);self.setFont('Guide',7.4);self.setFillColor(INK);self.drawString(48,29,'Tirtharaj Dhungana | MIT | Offline Learning Portal v1.0.0');self.drawString(48,17,'Contact: tirtharajdhungana84@gmail.com');self.drawRightString(547,29,f'{self._pageNumber} / {total}');super().showPage()
  super().save()
def main():
 ap=argparse.ArgumentParser();ap.add_argument('--font-dir');args=ap.parse_args();fonts(args.font_dir)
 body=ParagraphStyle('body',fontName='Guide',fontSize=10,leading=14,spaceAfter=7,textColor=INK)
 head=ParagraphStyle('head',fontName='GuideBold',fontSize=11.5,leading=15,spaceBefore=7,spaceAfter=7,textColor=TEAL)
 title=ParagraphStyle('title',fontName='GuideBold',fontSize=23,leading=28,spaceAfter=9,textColor=NAVY)
 sub=ParagraphStyle('sub',fontName='GuideBold',fontSize=15,leading=20,spaceAfter=12,textColor=NAVY)
 label=ParagraphStyle('label',fontName='GuideBold',fontSize=8.3,leading=11,spaceAfter=7,textColor=TEAL)
 codeStyle=ParagraphStyle('code',fontName='GuideMono',fontSize=8.8,leading=12,spaceBefore=4,spaceAfter=9,textColor=INK,backColor=colors.HexColor('#f2f4f6'),borderPadding=8)
 tstyle=ParagraphStyle('table',parent=body,fontSize=8.7,leading=12,spaceAfter=0)
 guides=json.loads((ROOT/'docs/guide_sources/guides.json').read_text())
 out=ROOT/'web/resources/Portal guides';out.mkdir(parents=True,exist_ok=True)
 for guide in guides:
  story=[]
  for i,pg in enumerate(guide['pages']):
   if i:story.append(PageBreak())
   story.append(Paragraph(f'GUIDE {guide["number"]} / '+('FIRST STEPS' if i==0 else guide['title'].upper()),label))
   if i==0:story.append(Paragraph(html.escape(guide['title']),title))
   story.append(Paragraph(html.escape(pg['title']),sub))
   for typ,val in pg['blocks']:
    if typ=='p':story.append(Paragraph(html.escape(val),body))
    elif typ=='h':story.append(Paragraph(html.escape(val),head))
    elif typ=='code':story.append(Preformatted(val,codeStyle,maxLineLength=92,splitChars=' ',newLineChars='  '))
    elif typ=='bullets':
     for x in val:story.append(Paragraph('&#8226; '+html.escape(x),body))
    elif typ=='diagram':story.extend([diagram(val),Spacer(1,10)])
    elif typ=='table':
     heads,rows=val;data=[[Paragraph(html.escape(x),tstyle) for x in row] for row in [heads]+rows]
     table=Table(data,colWidths=[155,344],hAlign='LEFT');table.setStyle(TableStyle([('BACKGROUND',(0,0),(-1,0),LIGHT),('VALIGN',(0,0),(-1,-1),'TOP'),('GRID',(0,0),(-1,-1),.4,colors.HexColor('#ccdce1')),('LEFTPADDING',(0,0),(-1,-1),8),('RIGHTPADDING',(0,0),(-1,-1),8),('TOPPADDING',(0,0),(-1,-1),7),('BOTTOMPADDING',(0,0),(-1,-1),7)]));story.extend([table,Spacer(1,10)])
  path=out/guide['filename'];SimpleDocTemplate(str(path),pagesize=(595,842),leftMargin=48,rightMargin=48,topMargin=43,bottomMargin=60,title=guide['title'],author='Tirtharaj Dhungana').build(story,canvasmaker=NumberedCanvas)
  Path(str(path)+'.meta.json').write_text(json.dumps({'title':guide['number']+' - '+guide['title'],'category':'Portal guides','language':'English','source':'Tirtharaj Dhungana - original portal guidance','rights':'MIT licence; Copyright 2026 Tirtharaj Dhungana','description':guide['description']},indent=2)+'\n')
  print(path)
if __name__=='__main__':main()
