import tempfile
import textwrap
import unittest
from pathlib import Path

from scripts.fix_svg_css_variables import fix_svg_css_variables


class FixSvgCssVariablesTests(unittest.TestCase):
  def _write_svg(self, content: str) -> Path:
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".svg")
    tmp.close()
    path = Path(tmp.name)
    path.write_text(textwrap.dedent(content), encoding="utf-8")
    self.addCleanup(path.unlink)
    return path

  def test_replaces_css_functions(self):
    svg_path = self._write_svg(
      """
      <svg>
        <rect fill="var(--fill-1, rgb(255, 0, 0))" />
        <circle stroke="var(--fill-2, rgba(0, 0, 0, 0.5))" />
        <path fill="var(--fill-3, hsl(200, 100%, 50%))" />
        <ellipse fill="var(--fill-4, #FBC343)" />
      </svg>
      """
    )

    found, replaced = fix_svg_css_variables(str(svg_path))
    self.assertEqual(found, 4)
    self.assertEqual(replaced, 4)

    rewritten = svg_path.read_text(encoding="utf-8")
    self.assertIn('fill="rgb(255, 0, 0)"', rewritten)
    self.assertIn('stroke="rgba(0, 0, 0, 0.5)"', rewritten)
    self.assertIn('fill="hsl(200, 100%, 50%)"', rewritten)
    self.assertIn('fill="#FBC343"', rewritten)

  def test_skips_when_fallback_missing(self):
    svg_path = self._write_svg(
      """
      <svg>
        <rect fill="var(--fill-1, )" />
        <path fill="var(--fill-2, var(--nested, #000))" />
      </svg>
      """
    )

    found, replaced = fix_svg_css_variables(str(svg_path))
    self.assertEqual(found, 2)
    self.assertEqual(replaced, 0)

    rewritten = svg_path.read_text(encoding="utf-8")
    self.assertIn('fill="var(--fill-1, )"', rewritten)
    self.assertIn('fill="var(--fill-2, var(--nested, #000))"', rewritten)


if __name__ == "__main__":
  unittest.main()
