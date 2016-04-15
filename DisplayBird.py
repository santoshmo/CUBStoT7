'''@author Samuel Tenka.
   Thanks to
   http://stackoverflow.com/questions/22835289/how-to-get-tkinter-canvas-to-dynamically-resize-to-window-width
'''

from tkinter import *
from PIL import Image, ImageTk
from GenerateColors import generate_colors
from ResizingCanvas import size_of_image, ResizingCanvas

labels = '''BACK BEAK BELLY BREAST CROWN FOREHEAD LEFT_EYE LEFT_LEG LEFT_WING NAPE RIGHT_EYE RIGHT_LEG RIGHT_WING TAIL THROAT'''.split()

class Visualizer:
    def __init__(self, imageid, bounding_boxes_name):
        self.image_dims = None
        self.setup_gui(imageid, bounding_boxes_name)
    def get_image_name(self):
        imageid = int(self.imageid_entry.get())
        with open('images.txt') as f:
            return 'images/'+f.read().split('\n')[imageid].split()[1]
    def setup_gui(self, imageid, bounding_boxes_name):
        self.master = Tk()
        self.canvas = ResizingCanvas(self.master, height=500+2, width=800+2)
        self.canvas.pack(fill=BOTH,expand=YES)
        b = Button(self.master, text='display', command=self.display); b.pack()
        self.imageid_entry = Entry(self.master); self.imageid_entry.pack()
        self.imageid_entry.insert(0,str(imageid))
        self.bounding_boxes_name_entry = Entry(self.master)
        self.bounding_boxes_name_entry.insert(0,bounding_boxes_name)
        self.bounding_boxes_name_entry.pack()
        self.master.bind('<Return>', lambda e: self.display())

    def refresh_canvas(self):
        self.canvas.delete('boxes')
        self.canvas.delete('text')
    def draw_box(self, box, color, label=None):
        (y,x,Y,X) = box if len(box)==4 else (box[0]-5,box[1]-5,box[0]+5,box[1]+5)
        hs,ws = self.scale_h, self.scale_w
        self.canvas.create_rectangle(x*ws+1,y*hs+1,X*ws+1,Y*hs+1, tag='boxes',
                                     outline=color, #fill=color,
                                     #stipple='gray50', activestipple='gray12',
                                     width=3, activewidth=7)
        if label:
            #contrast_color = 'black' if int(color[1:],16)>2**(24-1) else 'white'
            self.canvas.create_text((x+X)*ws/2+1-1,(y)*hs-5+1, text=label, tag='text', fill='black')
            self.canvas.create_text((x+X)*ws/2+1,(y)*hs-5, text=label, tag='text', fill=color)
    def display(self):
        self.refresh_canvas()
        image_name = self.get_image_name()
        h,w = size_of_image(image_name)
        self.scale_h, self.scale_w = self.canvas.height/h, self.canvas.width/w
        self.load_background()

        tocoor = lambda line: tuple(float(w) for w in line if w)
        with open('bounding_boxes.txt') as f:
            x,y,w,h = tocoor(f.read().split('\n')[int(self.imageid_entry.get())].split()[1:])
            bounding_box = y,x,y+h,x+w
            self.draw_box(bounding_box, 'black')

        bounding_boxes_name = self.bounding_boxes_name_entry.get()
        boxes = None
        if bounding_boxes_name:
            with open(self.bounding_boxes_name_entry.get()) as f:
                boxes = [tocoor(line.split()) for line in f.read().split('\n') if line]
        else:
            with open('parts/part_locs.txt') as f:
                imageid = int(self.imageid_entry.get())
                boxes = [tocoor(line.split()[2:4])[::-1] for line in f.read().split('\n')[15*imageid:15*(imageid+1)]] #keypoints
        for box,color,label in zip(boxes,generate_colors(),labels):
            if not sum(box): continue #skip invisible parts
            self.draw_box(box, color, label=label)

        self.canvas.tag_lower('boxes')
        self.canvas.tag_lower('image')

        mainloop()
    def load_background(self):
        h,w = self.canvas.height,self.canvas.width#self.canvas.winfo_reqheight(), self.canvas.winfo_reqwidth()
        image_name = self.get_image_name()
        if (h,w,image_name)==self.image_dims: return
        self.canvas.delete('image')
        self.image = Image.open(image_name)
        self.image = self.image.resize((w, h), Image.ANTIALIAS)
        self.image = ImageTk.PhotoImage(self.image)
        self.canvas.create_image(w/2 + 1, h/2 + 1, image=self.image, tag='image')
        self.image_dims = (h,w,image_name)

import sys
if __name__=='__main__':
    imageid=int(sys.argv[1]); bounding_boxes_name=sys.argv[2]
    V = Visualizer(imageid, bounding_boxes_name)
    V.display()
