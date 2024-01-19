# Jupyter notebook demo tools

`prepare-ipynb` is a small tool that allows you to automate modifications to
Jupyter notebooks that make them suitable for in-class demonstrations.

In particular, you can:

* `clear-marked-inputs`: "Clears" input cells. Generally, this will   delete/
  replace parts of the cell contents, so that, as an exercise   for the recipient of
  the notebook, these parts can be developed   from scratch. See the section on cell
  annotations below for what precisely this means.

* `clear-and-collase-marked-inputs`: Apply the same cell modifications as
  `clear-marked-inputs`, but also preserve a collapsed version of the original
  cell (with marks removed, see `remove-marks`) below. This cell can be
  expanded to reveal the solution.

* `clear-output`: Remove all output cells from the notebook, so that the
  results of the computation are more of a 'surprise' in class.

* `remove-marks`: Removes `#clear` marks to produce material suitable for
  distribution to students.

**Note:** Despite the name, the current version also supports Jupyter (v4)
notebooks.

## Cell annotations

Each cell annotation should appear or a line by itself.

- `#clear` (anywhere in the cell) deletes the entire contents of the cell.
- `#beginclear` / `#endclear` will remove all lines between the two marks,
  replacing `#beginclear` with an ellipsis (`...`).
