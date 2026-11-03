"""Editable vector diagrams for the ICAPS manuscript, in final-size points."""
import json
import math
from pathlib import Path

from reportlab.graphics import renderPDF, renderSVG
from reportlab.graphics.shapes import Drawing, Rect, Line, PolyLine, Polygon, Circle, String
from reportlab.lib.colors import HexColor, Color
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'paper/figures_2026_11_03_readability_v1'
for name, filename in [('Sans','arial.ttf'),('Bold','arialbd.ttf'),('Italic','ariali.ttf'),('Mono','consola.ttf')]:
    pdfmetrics.registerFont(TTFont(name, str(Path('C:/Windows/Fonts') / filename)))

INK = '#203047'
MUTED = '#5C6878'
LINE = '#CDD5DE'
BLUE = '#2369A8'
BLUE_BG = '#EEF5FC'
ORANGE = '#A75C13'
ORANGE_BG = '#FFF5E8'
PURPLE = '#7053A4'
PURPLE_BG = '#F4F0FA'
TEAL = '#147B73'
TEAL_BG = '#EDF7F5'
GRAY_BG = '#F5F7FA'
WHITE = '#FFFFFF'


class Figure:
    def __init__(self, width, height):
        self.w, self.h = width, height
        self.d = Drawing(width, height)
        # Embed the initial graphics-state font as well as visible text fonts.
        self.d.initialFontName = 'Sans'
        self.text_records = []

    def rect(self, x, y, w, h, fill=WHITE, stroke=LINE, radius=5, sw=.65, dash=None):
        r = Rect(x, self.h-y-h, w, h, rx=radius, ry=radius,
                 fillColor=HexColor(fill) if fill else None,
                 strokeColor=HexColor(stroke) if stroke else None,
                 strokeWidth=sw)
        if dash: r.strokeDashArray = dash
        self.d.add(r)

    def text(self, s, x, y, size=9, font='Sans', color=INK, anchor='start', max_width=None):
        width = pdfmetrics.stringWidth(s, font, size)
        if max_width is not None:
            assert width <= max_width+.2, (s, width, max_width)
        left = x - (width/2 if anchor == 'middle' else width if anchor == 'end' else 0)
        assert left >= -.2 and left+width <= self.w+.2, (s, left, width)
        assert y-size >= -.2 and y+3 <= self.h+.2, (s, y)
        self.d.add(String(x, self.h-y, s, fontName=font, fontSize=size,
                          fillColor=HexColor(color), textAnchor=anchor))
        self.text_records.append({'text':s,'x':x,'baseline_from_top':y,'font':font,'size':size,'width':width})

    def line(self, points, color=LINE, sw=.8, dash=None):
        arr = [value for x,y in points for value in (x,self.h-y)]
        p = PolyLine(arr, strokeColor=HexColor(color), strokeWidth=sw, fillColor=None)
        if dash: p.strokeDashArray = dash
        self.d.add(p)

    def arrow(self, points, color=INK, sw=.9, head=4, dash=None, both=False):
        self.line(points,color,sw,dash)
        def tip(a,b):
            angle=math.atan2(b[1]-a[1],b[0]-a[0])
            back=(b[0]-head*math.cos(angle),b[1]-head*math.sin(angle))
            normal=(-math.sin(angle)*head*.45,math.cos(angle)*head*.45)
            q=[b,(back[0]+normal[0],back[1]+normal[1]),(back[0]-normal[0],back[1]-normal[1])]
            self.d.add(Polygon([v for x,y in q for v in (x,self.h-y)],fillColor=HexColor(color),strokeColor=None))
        tip(points[-2],points[-1])
        if both: tip(points[1],points[0])

    def badge(self, label, x, y, color, r=6):
        self.d.add(Circle(x,self.h-y,r,fillColor=HexColor(color),strokeColor=None))
        self.text(label,x,y+2.7,8,'Bold',WHITE,'middle')

    def doc(self,x,y,w,h,color,label=None,fill=WHITE):
        self.rect(x,y,w,h,fill,color,2,.7)
        self.line([(x+w-7,y),(x+w-7,y+7),(x+w,y+7)],color,.7)
        if label:self.text(label,x+w/2,y+h*.58,8.5,'Bold',color,'middle')
        else:
            for k in range(3):self.line([(x+6,y+12+k*5),(x+w-7,y+12+k*5)],color,.55)

    def save(self,name):
        renderPDF.drawToFile(self.d,str(OUT/(name+'.pdf')),title=name)
        renderSVG.drawToFile(self.d,str(OUT/(name+'.svg')))
        (OUT/(name+'_layout.json')).write_text(json.dumps({'width_pt':self.w,'height_pt':self.h,'text':self.text_records},indent=2)+'\n',encoding='utf-8')


def pipeline():
    f=Figure(504,256)
    f.text('BUILD A REUSABLE DOMAIN',0,10,9,'Bold',INK)
    f.text('Inputs: domains + state I / source types; optional G',504,10,8.5,'Sans',MUTED,'end')
    cards=[(0,BLUE,BLUE_BG,'1','Select sources'),(130,PURPLE,PURPLE_BG,'2','Match facts'),(260,TEAL,TEAL_BG,'3','Build domain'),(390,INK,'#EFF3F8','4','Save domain')]
    for x,color,bg,num,title in cards:
        f.rect(x,21,112,111,bg,color,5,.8)
        f.badge(num,x+12,34,color)
        f.text(title,x+23,37,9.7,'Bold',color,max_width=85)
    for x in [112,242,372]:f.arrow([(x,76),(x+18,76)],INK,.85,3.5)

    f.doc(10,49,25,32,BLUE,'A');f.doc(43,49,25,32,ORANGE,'B')
    f.doc(76,49,25,32,'#AAB3BF','C',GRAY_BG)
    f.line([(78,79),(100,51)],'#AAB3BF',.8)
    f.text('Keep entire domains',56,97,9,'Bold',BLUE,'middle')
    f.text('All actions retained',56,111,9,'Sans',INK,'middle')
    f.text('IDs + source hashes',56,124,8.5,'Sans',MUTED,'middle')

    f.text('LLM judgments',186,53,9,'Bold',PURPLE,'middle')
    f.text('held_A(c,k)',186,70,9,'Mono',PURPLE,'middle')
    f.arrow([(186,75),(186,86)],PURPLE,.75,3,both=True)
    f.text('held_B(k,c)',186,99,9,'Mono',PURPLE,'middle')
    f.text('Check evidence + roles',186,113,8.5,'Sans',INK,'middle')
    f.text('Accept or keep separate',186,125,8.5,'Sans',MUTED,'middle')

    f.text('Object type checks',316,55,9,'Sans',INK,'middle')
    f.text('Keep source actions',316,70,9,'Bold',TEAL,'middle')
    f.line([(269,80),(363,80)],'#B5D5D0',.6)
    f.text('Optional action merge',316,93,8.5,'Bold',TEAL,'middle')
    f.text('pre: B_A OR B_B',316,108,9,'Mono',TEAL,'middle')
    f.text('Same effects + actors',316,123,8.5,'Sans',MUTED,'middle')

    f.doc(428,47,36,39,INK)
    f.text('Merged domain D*',446,100,9,'Bold',INK,'middle')
    f.text('Maps + source records',446,113,8.5,'Sans',INK,'middle')
    f.text('Reusable across worlds',446,125,8.5,'Sans',MUTED,'middle')

    # The saved artifact supplies both evaluations. No solver-to-merge feedback.
    f.line([(446,132),(446,152),(121,152)],INK,.85)
    f.arrow([(121,152),(121,170)],INK,.85,4)
    f.line([(383,152),(383,161)],INK,.85)
    f.arrow([(383,161),(383,170)],INK,.85,4)
    f.rect(149,142,207,20,WHITE,None,3)
    f.text('SAVED BEFORE ANY SEARCH',252.5,156,9,'Bold',INK,'middle')

    f.rect(0,171,242,71,GRAY_BG,LINE,5)
    f.text('(a) Check original plans',10,186,10,'Bold',INK)
    f.text('Original state I_i + available source plan',10,201,9,'Sans',MUTED)
    f.rect(10,211,63,20,WHITE,LINE,3)
    f.rect(90,211,67,20,WHITE,LINE,3)
    f.rect(174,211,58,20,WHITE,LINE,3)
    f.text('Translate',41.5,224.5,9,'Sans',INK,'middle')
    f.text('Replay in D*',123.5,224.5,9,'Sans',INK,'middle')
    f.text('Check goal',203,224.5,9,'Sans',INK,'middle')
    f.arrow([(73,221),(90,221)],INK,.75,3)
    f.arrow([(157,221),(174,221)],INK,.75,3)

    f.rect(262,171,242,71,GRAY_BG,LINE,5)
    f.text('(b) Find combined plans',272,186,10,'Bold',INK)
    f.text('State I + goal G + shared objects',272,201,9,'Sans',MUTED)
    for x,w,label in [(272,63,'Search D*'),(352,56,'Replay'),(425,69,'Check links')]:
        f.rect(x,211,w,20,WHITE,LINE,3)
        f.text(label,x+w/2,224.5,9,'Sans',INK,'middle')
    f.arrow([(335,221),(352,221)],INK,.75,3)
    f.arrow([(408,221),(425,221)],INK,.75,3)
    f.text('We check original plans and new event connections separately. Meaning and story quality need further evaluation.',252,253,8.5,'Italic',MUTED,'middle')
    f.save('figure2_construction_and_evaluation')


if __name__=='__main__':
    pipeline()
    print(json.dumps({'figures':1,'formats':['PDF','SVG'],'width_pt':504,'output':str(OUT)}))
