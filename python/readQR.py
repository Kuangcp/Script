from PIL import Image
import zbar

def get_QR():
    scanner = zbar.ImageScanner()
    scanner.parse_config("enable")
    pil = Image.open("one_qr_code.png").convert('L')
    width, height = pil.size
    raw = pil.tostring()
    image = zbar.Image(width, height, 'Y800', raw)
    scanner.scan(image)
    data = ''
    for symbol in image:
        data+=symbol.data
    del(image)
    return data

qrdata= get_QR()
print(qrdata)
