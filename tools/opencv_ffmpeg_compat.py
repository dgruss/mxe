#!/usr/bin/env python3
from pathlib import Path
import sys


def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: opencv_ffmpeg_compat.py <opencv_source_dir>")
        return 2
    source_dir = Path(sys.argv[1])
    path = source_dir / "modules" / "videoio" / "src" / "ffmpeg_codecs.hpp"
    if not path.exists():
        print(f"ffmpeg_codecs.hpp not found at {path}")
        return 1
    text = path.read_text()
    needle = "#ifndef MKTAG\n#define MKTAG(a,b,c,d) (a | (b << 8) | (c << 16) | (d << 24))\n#endif\n"
    if "CODEC_ID_H264 AV_CODEC_ID_H264" in text:
        return 0
    insert = (
        needle
        + "\n// Compatibility for newer FFmpeg where CODEC_ID_* were removed\n"
        + "#if defined(AV_CODEC_ID_H264) && !defined(CODEC_ID_H264)\n"
        + "#define CODEC_ID_H264 AV_CODEC_ID_H264\n"
        + "#define CODEC_ID_H263 AV_CODEC_ID_H263\n"
        + "#define CODEC_ID_H263P AV_CODEC_ID_H263P\n"
        + "#define CODEC_ID_H263I AV_CODEC_ID_H263I\n"
        + "#define CODEC_ID_H261 AV_CODEC_ID_H261\n"
        + "#define CODEC_ID_MPEG4 AV_CODEC_ID_MPEG4\n"
        + "#define CODEC_ID_MSMPEG4V3 AV_CODEC_ID_MSMPEG4V3\n"
        + "#define CODEC_ID_MSMPEG4V2 AV_CODEC_ID_MSMPEG4V2\n"
        + "#define CODEC_ID_MSMPEG4V1 AV_CODEC_ID_MSMPEG4V1\n"
        + "#define CODEC_ID_WMV1 AV_CODEC_ID_WMV1\n"
        + "#define CODEC_ID_WMV2 AV_CODEC_ID_WMV2\n"
        + "#define CODEC_ID_DVVIDEO AV_CODEC_ID_DVVIDEO\n"
        + "#define CODEC_ID_MPEG1VIDEO AV_CODEC_ID_MPEG1VIDEO\n"
        + "#define CODEC_ID_MPEG2VIDEO AV_CODEC_ID_MPEG2VIDEO\n"
        + "#define CODEC_ID_MJPEG AV_CODEC_ID_MJPEG\n"
        + "#define CODEC_ID_LJPEG AV_CODEC_ID_LJPEG\n"
        + "#define CODEC_ID_HUFFYUV AV_CODEC_ID_HUFFYUV\n"
        + "#define CODEC_ID_FFVHUFF AV_CODEC_ID_FFVHUFF\n"
        + "#define CODEC_ID_CYUV AV_CODEC_ID_CYUV\n"
        + "#define CODEC_ID_RAWVIDEO AV_CODEC_ID_RAWVIDEO\n"
        + "#define CODEC_ID_INDEO3 AV_CODEC_ID_INDEO3\n"
        + "#define CODEC_ID_VP3 AV_CODEC_ID_VP3\n"
        + "#define CODEC_ID_ASV1 AV_CODEC_ID_ASV1\n"
        + "#define CODEC_ID_ASV2 AV_CODEC_ID_ASV2\n"
        + "#define CODEC_ID_VCR1 AV_CODEC_ID_VCR1\n"
        + "#define CODEC_ID_FFV1 AV_CODEC_ID_FFV1\n"
        + "#define CODEC_ID_XAN_WC4 AV_CODEC_ID_XAN_WC4\n"
        + "#define CODEC_ID_MSRLE AV_CODEC_ID_MSRLE\n"
        + "#define CODEC_ID_MSVIDEO1 AV_CODEC_ID_MSVIDEO1\n"
        + "#define CODEC_ID_CINEPAK AV_CODEC_ID_CINEPAK\n"
        + "#define CODEC_ID_TRUEMOTION1 AV_CODEC_ID_TRUEMOTION1\n"
        + "#define CODEC_ID_MSZH AV_CODEC_ID_MSZH\n"
        + "#define CODEC_ID_ZLIB AV_CODEC_ID_ZLIB\n"
        + "#define CODEC_ID_SNOW AV_CODEC_ID_SNOW\n"
        + "#define CODEC_ID_4XM AV_CODEC_ID_4XM\n"
        + "#define CODEC_ID_FLV1 AV_CODEC_ID_FLV1\n"
        + "#define CODEC_ID_SVQ1 AV_CODEC_ID_SVQ1\n"
        + "#define CODEC_ID_TSCC AV_CODEC_ID_TSCC\n"
        + "#define CODEC_ID_ULTI AV_CODEC_ID_ULTI\n"
        + "#define CODEC_ID_VIXL AV_CODEC_ID_VIXL\n"
        + "#endif\n"
    )
    if needle in text:
        path.write_text(text.replace(needle, insert))
        return 0
    print("MKTAG block not found; patch not applied")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
