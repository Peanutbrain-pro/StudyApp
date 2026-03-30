from PIL import Image, ImageDraw, ImageFont


def debug_bbox(image_path, bbox_list, label="Figure"):
    img = Image.open(image_path).convert("RGB")
    orig_w, orig_h = img.size
    draw = ImageDraw.Draw(img)

    print(f"Original image size: {orig_w} × {orig_h}")
    print(f"Model bbox (0–1000 normalized): {bbox_list}")

    # Assume model uses 0–1000 scale for both axes
    # → convert to fractions (0.0–1.0), then scale to real pixels
    x1 = int(bbox_list[0] / 1000.0 * orig_w)
    y1 = int(bbox_list[1] / 1000.0 * orig_h)
    x2 = int(bbox_list[2] / 1000.0 * orig_w)
    y2 = int(bbox_list[3] / 1000.0 * orig_h)

    print(f"Scaled to your image pixels: [{x1}, {y1}, {x2}, {y2}]")

    if x1 >= x2 or y1 >= y2:
        print(
            "⚠️ Warning: invalid bbox (x1 >= x2 or y1 >= y2) — model might have swapped coords"
        )

    # Draw very thick, visible box
    draw.rectangle([x1, y1, x2, y2], outline="red", width=12)
    draw.rectangle([x1, y1, x2, y2], outline="lime", width=5)  # extra contrast border

    # Add label with background for readability
    try:
        font = ImageFont.truetype("arial.ttf", 48)
    except:
        font = ImageFont.load_default()

    text_x, text_y = x1 + 10, y1 + 10
    # Optional: semi-transparent bg behind text
    bbox_text = draw.textbbox((text_x, text_y), label, font=font)
    draw.rectangle(bbox_text, fill=(255, 255, 255, 180))  # white semi-transparent
    draw.text(
        (text_x, text_y),
        label,
        fill="red",
        font=font,
        stroke_width=2,
        stroke_fill="black",
    )

    img.show()  # opens in viewer
    img.save("DEBUG_bbox_scaled_0-1000.png")
    print("✅ Saved annotated image: DEBUG_bbox_scaled_0-1000.png")
    print(
        "   Open it and check if the red/lime box covers the intended region (e.g. a diagram)."
    )


# ================== USAGE ==================
image_path = "Screenshot 2026-03-03 204129.png"  # your file name

# Paste ONE bbox from your model's latest output here, e.g.:
# bbox = [10, 986, 980, 995]  # example — replace with real one
bbox = [162, 153, 567, 627]
# or try another: [10, 754, 980, 863]

debug_bbox(image_path, bbox, label="Distributive Example")
