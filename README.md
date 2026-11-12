# OverEngineeringSudoku

## Description:

This was a fun project I had to complete after falling in love with the game Sudoku

## Generator rules

The rules of the generator follow the rules of the game and necessitate it follows the same rules, that being:

1. Every cell can only be occupied by a digit ranging from 1-9 (inclusive)
2. Each row can only contain a single digit from that range
3. Each column can only contain a single digit from that range
4. Each subgrid (width and height equal to the square of the grid size) can only contain a single digit from that range  

## Algorithm

For starters, this implementation takes advantage of the property of the Sudoku grid that **diagonal subgrids do not suffer from collisions** under the latter three rules of the game.

This allows us to randomly fill the diagonal subgrids from top-left to bottom-right as a first step.

Then, we recursively can fill the rest of the empty cells, skipping already filled cells and ensuring each digit placed respects the rules.

If we encounter no further digits can possibly be placed, we backtrack to previous cells and try other digits in increasing order.

Finally, we randomly remove an amount of digits in correspondence with the desired difficulty.

## Optimizations

### Explicit stack over recursion

The first intuitive optimization I made to this implementation was using an explicit stack to avoid the function call overhead.

To be more specific, recursively calling the fillRemaining function may involve stack allocating extra values such as the return location and last attempted value.

Storing the last-attempted value in the call stack is not necessary as well due to the fact that the value can be derived from the state of the grid when backtracking.

### Bit mask over row, column, and subgrid scan

After completing the normal grid-based approach, I discovered using Bit Masks to represent row-wise, columnar, and subgrid-wise presence of numbers 1-9.

For instance, a row containing only 5 can be represented in binary with the value 0b000010000.

A column containing the values 2, 4, and 8 would be 0b010001010.

A fully filled subgrid would be 0b111111111, as all the numbers 1-9 are present.

This allows an 0(1) lookup of the placement of a given digit being legal. 

## Further Improvements

I intentionally stopped at the bit-masking step since the further optimizations involve scanning for the least-likely-to-backgrack positions and filling those in first to reduce the amount of backgtracking.
 
