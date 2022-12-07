# Code Style

When wanting to contribute to Funkin': Feather, please make sure to stick to the following requirements:

---
## Formatted `.hx` files

Please format the files you have modified by using Haxe's own formatter. **To install it, simply run**:
```
haxelib install formatter
```

To run the `formatter`, execute the following:
```
haxelib run formatter -s <path>
```

(the `-s` stands for `source`) || (`<path>` dictates the path of the `file` or `directory` with `.hx` files)

## Variable naming
Variable names should be concise and properly labled for the sake of explaining their functionality.

## Long functions / Important variables
If a funcion is long or if a variable is imporant, you should leave a comment explaining it / what it does. 

For example: `// this function/variable is cool 'cause [insert explanation here]`

## Optimization
*Obviously*, before contributing to the repository it is **required** that you test the changes that you want to push and see if they're stable and running properly.