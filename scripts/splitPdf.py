import os
import sys

import pypdf


def splitPdf():
    """
    Split pdf into multiple pdfs.
    Run using: ./splitPdf.exe "output location" "input locations" ...
    """
    print(sys.argv)
    if len(sys.argv) <= 1:
        print("Provide output location and filepaths for pdfs")
        return

    outputFolder = sys.argv[1]

    os.makedirs(outputFolder, exist_ok=True)
    filePaths = sys.argv[2:]

    for filePath in filePaths:
        if filePath[-4:] != ".pdf":
            continue
        reader = pypdf.PdfWriter(clone_from=filePath)
        if reader is None:
            print("Couldn't read from file location: ", filePath)
            continue

        num_pages = len(reader.pages)
        file_name = os.path.basename(filePath)

        for i in range(num_pages):
            writer = pypdf.PdfWriter()

            # reducing size
            for img in reader.pages[i].images:
                img.replace(img.image, quality=65)
            reader.pages[i].compress_content_streams()

            writer.add_page(reader.pages[i])

            out_path = (
                outputFolder + "\\" + file_name[:-3] + "_page_" + str(i + 1) + ".pdf"
            )
            with open(out_path, "wb") as output_pdf:
                writer.write(output_pdf)
            print(f"Created: {out_path}")


splitPdf()
