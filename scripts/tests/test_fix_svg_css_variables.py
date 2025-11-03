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

  def test_raises_file_not_found(self):
    missing = Path("/tmp/definitely_missing_file_1234567890.svg")
    if missing.exists():
      # Ensure it doesn't exist for the test scenario
      missing.unlink()
    with self.assertRaises(FileNotFoundError):
      fix_svg_css_variables(str(missing))

  def test_raises_value_error_on_non_svg(self):
    tmp = tempfile.NamedTemporaryFile(delete=False, suffix=".txt")
    tmp.close()
    path = Path(tmp.name)
    try:
      path.write_text("not an svg", encoding="utf-8")
      with self.assertRaises(ValueError):
        fix_svg_css_variables(str(path))
    finally:
      path.unlink(missing_ok=True)

  def test_partial_replacement(self):
    svg_path = self._write_svg(
      """
      <svg>
        <rect fill="var(--fill-a, #ff0000)" />
        <circle fill="var(--fill-b, var(--nested, #00ff00))" />
      </svg>
      """
    )
    found, replaced = fix_svg_css_variables(str(svg_path))
    self.assertGreaterEqual(found, 2)
    self.assertEqual(replaced, 1)
    rewritten = svg_path.read_text(encoding="utf-8")
    # Valid replacement applied
    self.assertIn('fill="#ff0000"', rewritten)
    # Nested var fallback is retained as-is (skipped)
    self.assertIn('fill="var(--fill-b, var(--nested, #00ff00))"', rewritten)


if __name__ == "__main__":
  unittest.main()
