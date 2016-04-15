from tkinter import *
from PIL import Image, ImageTk

def size_of_image(image_name):
    im=Image.open(image_name)
    return im.size[::-1] #[height,width]

class ResizingCanvas(Canvas):
    ''' A subclass of Canvas for dealing with resizing of windows
        Thanks to
        http://stackoverflow.com/questions/22835289/how-to-get-tkinter-canvas-to-dynamically-resize-to-window-width
    '''
    def __init__(self,parent,**kwargs):
        Canvas.__init__(self,parent,**kwargs)
        self.bind("<Configure>", self.on_resize)
        self.height = self.winfo_reqheight()
        self.width = self.winfo_reqwidth()

    def on_resize(self,event):
        scale_h = float(event.height)/self.height
        scale_w = float(event.width)/self.width
        self.height = event.height
        self.width = event.width
        # rescale all the objects tagged with the "all" tag
        self.scale("all",0,0,scale_w,scale_h)
