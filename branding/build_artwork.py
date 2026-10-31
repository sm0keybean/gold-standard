"""Render original geometric listing artwork; requires Pillow, no game assets."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

OUT = Path(__file__).parent / 'listing'
OUT.mkdir(exist_ok=True)
NAVY, GOLD, MUTED, WHITE = '#0e141c', '#dbb05c', '#273442', '#f3eee3'

def cover():
    im = Image.new('RGB', (1920,1080), NAVY)
    d = ImageDraw.Draw(im)
    # Quiet ledger grid, two denominations and a two-way conversion motif.
    for x in range(120,1920,120): d.line((x,120,x,960),fill='#141e29',width=1)
    for y in range(120,1080,120): d.line((120,y,1800,y),fill='#141e29',width=1)
    for x,y,r in [(650,540,216),(1270,540,216)]:
        d.ellipse((x-r,y-r,x+r,y+r),fill='#16212c',outline=GOLD,width=7)
        d.ellipse((x-r+23,y-r+23,x+r-23,y+r-23),outline=MUTED,width=3)
    # Distinct minted marks: a single bar and a pair of bars.
    d.rounded_rectangle((628,430,672,650),radius=15,fill=GOLD)
    for x in (1224,1292): d.rounded_rectangle((x,430,x+36,650),radius=12,fill=GOLD)
    d.line((880,491,1030,491),fill=GOLD,width=12)
    d.polygon([(1057,491),(1023,470),(1023,512)],fill=GOLD)
    d.line((890,589,1040,589),fill=GOLD,width=12)
    d.polygon([(863,589),(897,568),(897,610)],fill=GOLD)
    im.save(OUT/'gold-standard-cover.png', optimize=True)
    return im

def banner():
    im=Image.new('RGB',(1920,1080),NAVY)
    d=ImageDraw.Draw(im)
    d.rounded_rectangle((126,150,416,440),radius=52,outline=GOLD,width=5)
    serif=ImageFont.truetype('C:/Windows/Fonts/georgiab.ttf',150)
    d.text((270,285),'GS',font=serif,fill=GOLD,anchor='mm')
    title=ImageFont.truetype('C:/Windows/Fonts/seguisb.ttf',108)
    sub=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',48)
    small=ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf',32)
    d.text((126,518),'GOLD STANDARD',font=title,fill=WHITE)
    d.text((132,668),'Your world. Your currency.',font=sub,fill=GOLD)
    d.line((132,792,1788,792),fill=MUTED,width=2)
    d.text((132,844),'CURRENCY STUDIO  /  TRANSPORT FEVER 3',font=small,fill='#b9c2cc')
    d.text((1788,844),'by sm0keybean',font=small,fill=GOLD,anchor='ra')
    im.save(OUT/'gold-standard-banner.png',optimize=True)

cover()
banner()
for p in OUT.glob('*.png'):
    with Image.open(p) as im:
        assert im.size == (1920,1080)
    assert p.stat().st_size < 8_000_000
    print(p.name, p.stat().st_size, 'bytes; 1920 x 1080')
