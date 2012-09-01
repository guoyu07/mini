#include "FreeImage.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <getopt.h>

#define STR_HTML_HEADER	\
	"<!--Generated using img2html, by cys -->\n\n"
#define STR_HTML_BEGIN		\
	"<html><head><title>IMG2HTML</title></head><body>\n"
#define STR_HTML_END		\
	"\n</pre></font>\n \
	<!-- IMAGE ENDS HERE -->\n \
	</td></tr></table>\n</body></html>"
#define STR_FONT_HTML_START	\
	"<font style=\"color:"
#define STR_FONT_HTML_END	\
	"</font>"
#define STR_TABLE_BEGIN	\
	"<table style=\"text-align:center; padding:10px\">\n \
	<tr style=\"background-color:black\"><td>\n\n \
	<!-- IMAGE BEGINS HERE -->\n \
	<font style=\"font-size:0.5em\">\n \
	<pre>"

//CSS color string
static char html_color[64];

#define OC_RED_INDEX	0
#define OC_GREEN_INDEX	1
#define OC_BLUE_INDEX	2
static BYTE old_color[3];

static char chars[] = {'0', '1'};

static char next_char(void)
{
	static int i = 0;
	return chars[(i++)%2];
}

static int rgb_equal_old(BYTE r, BYTE g, BYTE b)
{
	if (old_color[OC_RED_INDEX] == r && 
		old_color[OC_GREEN_INDEX] == g && 
		old_color[OC_BLUE_INDEX] == b)
	{
		return 1;
	}
	return 0;
}

static void make_html_color(BYTE red, BYTE green, BYTE blue)
{
	sprintf(html_color, "rgb(%d,%d,%d);\"", red, green, blue);
}

static char *img_path;
static int out_width;
static int out_type;

static struct option long_opts[] = 
{
	{"image", required_argument, 0, 'f'},
	{"width", required_argument, 0, 'x'},
	{"chars", required_argument, 0, 'c'},
	{"html", no_argument, &out_type, 0},
	{"text", no_argument, &out_type, 1},
	{0, 0, 0, 0}
};

static int parse_opts(int argc, char **argv)
{
	int opt_idx = 0;
	int c;

	while (1)
	{
		c = getopt_long(argc, argv, "c:f:hx:", long_opts, &opt_idx);
		if (c == -1)
			break;
		
		switch (c)
		{
			case 0:
				break;
			case 'c':
				fprintf(stderr, "-c not implemented yet\n");
				break;
			case 'f':
				if (optarg)
				{
					int len = strlen(optarg);
					img_path = (char *)malloc(len+1);
					memmove(img_path, optarg, len);
					img_path[len] = 0;
					
				}
				else
				{
					fprintf(stderr, "-f needs argument\n");
					return -1;
				}
				break;
			case 'x':
				if (optarg)
				{
					out_width = atoi(optarg);
				}
				else
				{
					fprintf(stderr, "-x needs argument\n");
					return -1;
				}
				break;
			case 'h':
				//fall thru
			default:
				return -1;
				break;
		}
	}
	//unknown things
	if (optind < argc)
	{
		fprintf(stderr, "mystery things: ");
		while (optind < argc)
			fprintf(stderr, "%s ", argv[optind++]);
		fprintf(stderr, "\n");
		return -1;
	}
	if (!img_path)
		return -1;
	return 0;
}

void usage(void)
{
	fprintf(stderr, "\nIMG2HTML by cys\n"
		"-h,	--help	show this help\n"
		"-f,	--image	specify a image file\n"
		"-x,	--width	specify the width of output picture\n"
		"-c,	--chars	specify characters to use\n"
		"	--html	specify output file type as html\n"
		"	--text	specify output file type as plain text\n"
		);
}

/**
FreeImage error handler
@param fif Format / Plugin responsible for the error
@param message Error message
*/
void fi_error_handler(FREE_IMAGE_FORMAT fif, const char *message)
{
	fprintf(stderr, "\n*** ");
	if (fif != FIF_UNKNOWN)
	{
		fprintf(stderr, "%s Format\n", FreeImage_GetFormatFromFIF(fif));
	}
	fprintf(stderr, "%s", message);
	fprintf(stderr ," ***\n");
}

FIBITMAP* generic_img_loader(const char *img, int flag)
{
	FREE_IMAGE_FORMAT fif = FIF_UNKNOWN;

	//check the file signature
	fif = FreeImage_GetFileType(img, 0);
	if (fif == FIF_UNKNOWN)
	{
		//no signature, check filename extension
		fif = FreeImage_GetFIFFromFilename(img);
	}
	if ((fif != FIF_UNKNOWN) && (FreeImage_FIFSupportsReading(fif)))
	{
		FIBITMAP *dib = FreeImage_Load(fif, img, flag);
		return dib;
	}
	return NULL;
}

int main(int argc, char **argv)
{
	FIBITMAP *dib, *dptr;
	RGBQUAD color;
	unsigned int width, height, bpp, bytespp;
	int x, y;
	int ret = 0;

	if (parse_opts(argc, argv) < 0)
	{
		usage();
		return -1;
	}

	//capture error msg from FreeImage
	FreeImage_SetOutputMessage(fi_error_handler);
	
	FreeImage_Initialise(TIFF_DEFAULT);

	dib = generic_img_loader(img_path, 0);
	if (!dib)
	{
		ret = -1;
		goto err_deinit;
	}

	if (FALSE == FreeImage_HasPixels(dib))
	{
		ret = -1;
		fprintf(stderr, "%s doesn't contain pixel data\n", img_path);
		goto out;
	}
	
	bpp = FreeImage_GetBPP(dib);
	width = FreeImage_GetWidth(dib);
	height = FreeImage_GetHeight(dib);
	if (out_width > 0)
	{
		//if original size > user specified size, scale the image
		if (width > out_width)
		{
			int out_height;
			out_height = (out_width * height) / width;
			dptr = FreeImage_Rescale(dib, out_width, out_height, FILTER_BSPLINE);
			FreeImage_Unload(dib);
			if (!dptr)
			{
				ret = -1;
				goto err_deinit;
			}
			dib = dptr;
		}
	}
	width = FreeImage_GetWidth(dib);
	height = FreeImage_GetHeight(dib);
#if 0
	// Calculate the number of bytes per pixel (3 for 24-bit or 4 for 32-bit)
	bytespp = FreeImage_GetLine(dib) / FreeImage_GetWidth(dib);
#endif
#if 0
	printf("bpp=%u\n", bpp);
	printf("width=%u height=%u\n", width, height);
	switch (FreeImage_GetColorType(dib))
	{
		case FIC_RGB:
			printf("RGB\n");
			break;
		case FIC_RGBALPHA:
			printf("RGBA\n");
			break;
		default:
			printf("other\n");
			break;
	}
#endif
	
	printf(STR_HTML_HEADER);
	printf(STR_HTML_BEGIN);
	printf(STR_TABLE_BEGIN);

	for (y = height-1; y >= 0; --y)
	{
#if 0
		BYTE *bits = FreeImage_GetScanLine(dib, y);
#endif
		for (x = 0; x < width; ++x)
		{
#if 1
			if (FALSE == FreeImage_GetPixelColor(dib, x, y, &color))
			{
				fprintf(stderr, "ERROR: getting pixel color failed -- %d:%d\n", x, y);
				ret = -1;
				goto out;
			}
			
			BYTE red = color.rgbRed;
			BYTE green = color.rgbGreen;
			BYTE blue = color.rgbBlue;
#endif
#if 0
			BYTE red = bits[FI_RGBA_RED];
			BYTE green = bits[FI_RGBA_GREEN];
			BYTE blue = bits[FI_RGBA_BLUE];
#endif


			if (!rgb_equal_old(red, green, blue))
			{
				make_html_color(red, green, blue);
				if (x == 0)
				{
					printf(STR_FONT_HTML_START"%s>%c", html_color, next_char());
				}
				else
				{
					printf(STR_FONT_HTML_END STR_FONT_HTML_START"%s>%c", html_color, next_char());
				}
				old_color[0] = red;
				old_color[1] = green;
				old_color[2] = blue;
			}
			else
			{
				printf("%c", next_char());
			}
#if 0
			// jump to next pixel
			bits += bytespp;
#endif
		}
		memset(old_color, 0, sizeof(old_color));
		printf(STR_FONT_HTML_END"<br>");
	}

	//done
       	printf(STR_HTML_END);

out:
	FreeImage_Unload(dib);
err_deinit:
	FreeImage_DeInitialise();

	free(img_path);
	
	return ret;
}
