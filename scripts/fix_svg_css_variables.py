#!/usr/bin/env python3
"""
Fix SVG CSS Variables for flutter_svg compatibility.

Figma exports SVGs with CSS Custom Properties (e.g., fill="var(--fill-0, #FBC343)")
which flutter_svg does not support. This script replaces CSS variable patterns
with their fallback color values.

Usage:
    python3 scripts/fix_svg_css_variables.py <path-to-svg-file>

Example:
    python3 scripts/fix_svg_css_variables.py assets/images/onboarding/trophy.svg

The script will:
1. Read the SVG file
2. Find all CSS variable patterns: var(--fill-N, COLOR)
3. Replace them with the fallback COLOR value
4. Overwrite the original file with the fixed version
5. Print statistics (variables found, variables replaced)

Exit codes:
    0: Success
    1: File not found
    2: Invalid file format (not SVG)
    3: No changes needed (no CSS variables found)
"""

import re
import sys
from pathlib import Path


def fix_svg_css_variables(svg_path: str) -> tuple[int, int]:
    """
    Replace CSS variable patterns in SVG with their fallback colors.

    Args:
        svg_path: Path to the SVG file to fix

    Returns:
        Tuple of (variables_found, variables_replaced)

    Raises:
        FileNotFoundError: If SVG file does not exist
        ValueError: If file is not an SVG
    """
    svg_file = Path(svg_path)

    if not svg_file.exists():
        raise FileNotFoundError(f"SVG file not found: {svg_path}")

    if svg_file.suffix.lower() != '.svg':
        raise ValueError(f"File is not an SVG: {svg_path}")

    # Read SVG content
    content = svg_file.read_text(encoding='utf-8')

    # Pattern: var(--fill-N, COLOR) where COLOR can be #HEX or named color (white, black, etc.)
    # Capture group 1: the fallback color
    pattern = r'var\(--fill-\d+,\s*((?:[^()]|\([^)]*\))+?)\)'

    # Count matches before replacement
    variables_found = len(re.findall(pattern, content))

    if variables_found == 0:
        return (0, 0)

    # Replace: keep only the fallback color
    def replace_css_var(match):
        fallback_color = match.group(1).strip()
        return fallback_color

    fixed_content = re.sub(pattern, replace_css_var, content)

    # Count matches after replacement (should be 0)
    variables_remaining = len(re.findall(pattern, fixed_content))
    variables_replaced = variables_found - variables_remaining

    temp_path = svg_file.with_suffix('.svg.tmp')

    try:
        if temp_path.exists():
            temp_path.unlink()

        temp_path.write_text(fixed_content, encoding='utf-8')
        temp_path.replace(svg_file)
    except Exception:
        if temp_path.exists():
            temp_path.unlink()
        raise

    return (variables_found, variables_replaced)


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 fix_svg_css_variables.py <path-to-svg-file>")
        print("\nExample:")
        print("  python3 scripts/fix_svg_css_variables.py assets/images/onboarding/trophy.svg")
        sys.exit(1)

    svg_path = sys.argv[1]

    try:
        found, replaced = fix_svg_css_variables(svg_path)

        if found == 0:
            print(f"✅ No CSS variables found in {svg_path}")
            print("   File is already compatible with flutter_svg.")
            sys.exit(3)

        if replaced == found:
            print(f"✅ Fixed SVG: {svg_path}")
            print(f"   CSS variables found: {found}")
            print(f"   CSS variables replaced: {replaced}")
            print(f"   Remaining CSS variables: 0")
            print("\n🔄 Next step: Hot Restart your Flutter app (not just hot reload)")
            sys.exit(0)
        else:
            print(f"⚠️  Partial fix: {svg_path}")
            print(f"   CSS variables found: {found}")
            print(f"   CSS variables replaced: {replaced}")
            print(f"   Remaining CSS variables: {found - replaced}")
            print("\n⚠️  Some CSS variables could not be replaced.")
            print("   Please check the file manually or report this edge case.")
            sys.exit(0)

    except FileNotFoundError as e:
        print(f"❌ Error: {e}")
        print(f"\n💡 Tip: Run this script from the project root:")
        print(f"   python3 scripts/fix_svg_css_variables.py {svg_path}")
        sys.exit(1)

    except ValueError as e:
        print(f"❌ Error: {e}")
        print(f"\n💡 Expected file extension: .svg")
        sys.exit(2)

    except Exception as e:
        print(f"❌ Unexpected error: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
