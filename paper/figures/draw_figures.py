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
OUT = ROOT / 'paper/figures_2026_11_03_v1'
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


def motivation():
    f=Figure(504,226)
    f.rect(0,0,504,29,GRAY_BG,None,5)
    f.text('EXPLICIT WORLD',9,11,8.5,'Bold',MUTED)
    f.text('c = Mira   k = brass key   a = archive',107,11,9,'Sans',INK)
    f.text('Initially: key not held; archive locked; gift route enabled.',9,24,9)
    f.text('Goal: evidence(c)',493,24,9,'Bold',INK,'end')

    # Source colors remain attached to their actions throughout the diagram.
    f.rect(0,39,151,111,BLUE_BG,BLUE,6,.8)
    f.badge('A',12,51,BLUE)
    f.text('Acquire a key',24,54,10.3,'Bold',BLUE)
    variants=[('buy(c,k)','payment',64),('receive(c,k)','gift',86),('steal(c,k)','unguarded',108)]
    for name,guard,y in variants:
        selected=name.startswith('receive')
        f.rect(9,y,133,18,WHITE,BLUE if selected else '#CADDEC',4,1.1 if selected else .6)
        f.text(name,15,y+12,9,'Mono',BLUE)
        f.text(guard,136,y+12,8.5,'Sans',MUTED,'end')
    f.text('can establish held_A(c,k)',75.5,142,8.5,'Sans',BLUE,'middle')

    f.rect(169,39,166,111,PURPLE_BG,PURPLE,6,.8)
    f.text('Interface + shared entities',252,54,10,'Bold',PURPLE,'middle')
    f.text('held_A(c,k)',252,77,10,'Mono',PURPLE,'middle')
    f.arrow([(252,81),(252,97)],PURPLE,.8,3,both=True)
    f.text('held_B(k,c)',252,111,10,'Mono',PURPLE,'middle')
    f.text('Same Mira; same brass key',252,129,9,'Sans',INK,'middle')
    f.text('holder / item roles preserved',252,142,8.5,'Sans',MUTED,'middle')
    f.arrow([(151,95),(169,95)],PURPLE,.8,3,dash=[2,2])
    f.arrow([(335,95),(353,95)],PURPLE,.8,3,dash=[2,2])

    f.rect(353,39,151,111,ORANGE_BG,ORANGE,6,.8)
    f.badge('B',365,51,ORANGE)
    f.text('Retrieve evidence',377,54,10,'Bold',ORANGE,max_width=120)
    f.rect(362,64,133,28,WHITE,'#E9D4BC',4)
    f.text('unlock(c,k,a)',428.5,76,9,'Mono',ORANGE,'middle')
    f.text('requires held_B(k,c)',428.5,87,8.5,'Sans',MUTED,'middle')
    f.arrow([(428.5,93),(428.5,102)],ORANGE,.8,3)
    f.rect(362,105,133,28,WHITE,'#E9D4BC',4)
    f.text('retrieve(c,e,a)',428.5,117,9,'Mono',ORANGE,'middle')
    f.text('requires unlocked(a)',428.5,128,8.5,'Sans',MUTED,'middle')
    f.text('e = evidence in the archive',428.5,144,8.5,'Sans',MUTED,'middle')

    f.text('ONE ENABLED CROSS-SOURCE ROUTE',0,164,9,'Bold',INK)
    for x,label,event,color,bg in [(0,'A','receive(c,k)',BLUE,BLUE_BG),(185,'B','unlock(c,k,a)',ORANGE,ORANGE_BG),(370,'B','retrieve(c,e,a)',ORANGE,ORANGE_BG)]:
        f.rect(x,178,134,29,bg,color,5,.8)
        f.badge(label,x+13,192.5,color)
        f.text(event,x+27,196,9.5,'Mono',color,max_width=103)
    f.text('key held',159.5,185,8.5,'Sans',MUTED,'middle')
    f.arrow([(134,196),(185,196)],INK,.9,4)
    f.text('unlocked',344.5,185,8.5,'Sans',MUTED,'middle')
    f.arrow([(319,196),(370,196)],INK,.9,4)
    f.text('Distinct acquisition events remain separate.',0,222,8.5,'Italic',MUTED)
    f.line([(291,219),(305,219)],PURPLE,.8,[2,2]);f.text('correspondence',310,222,8.5,'Sans',MUTED)
    f.arrow([(408,219),(422,219)],INK,.8,3);f.text('causal link',427,222,8.5,'Sans',MUTED)
    f.save('figure1_causal_composition')



if __name__=='__main__':
    motivation()
    print(json.dumps({'figures':1,'formats':['PDF','SVG'],'width_pt':504,'output':str(OUT)}))
