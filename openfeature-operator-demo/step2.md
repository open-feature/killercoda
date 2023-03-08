# OpenFeature Hooks

[Exploring the code](https://github.com/open-feature/playground/blob/0b74b12fe84421f2d12dd14767e77fb3450ee539/packages/app/src/app/hex-color/hex-color.service.ts#L9) you may notice that an `after`{{}} hook has been defined. [Hooks](https://docs.openfeature.dev/docs/reference/concepts/hooks/) are a powerful feature that can be used to extend OpenFeature capabilities. In this case, the code is expecting a valid CSS hex color value. However, the person configuring the feature flag in a remote feature flag management tool may not be aware of this requirement. That's where a validation hook could be used to ensure only valid CSS values are returned. 

In this hook, the evaluated value is tested against a regular expression. If it doesn't match, a warning message is logged and the hook throws an error. OpenFeature will catch the error and return the default value.

In this case, [the default color is set to](https://github.com/open-feature/playground/blob/0b74b12fe84421f2d12dd14767e77fb3450ee539/packages/app/src/app/hex-color/hex-color.service.ts#L10) `#000000`{{}} (black).

# Use an Invalid CSS Color

Examine `~/feature-flag-configuration.yaml`{{}} again. Notice line `22`{{}} has a variant defined as `yellow: yellow`{{}}. The word `yellow`{{}} is an invalid hex color (remember that the `after`{{}} hook is expecting a `#`{{}} followed by a combination of any `6`{{}} digits, `a-f`{{}} or `A-F`{{}}) (eg. `#FFFF00`{{}}).

If we try to use the `yellow`{{}} variant, we should expect the `after`{{}} hook to fail and the application will fall back to the default `black`{{}} color.

Try this now:

```
sed -i 's/defaultVariant: green/defaultVariant: yellow/g' ~/feature-flag-configuration.yaml
kubectl apply -f ~/feature-flag-configuration.yaml
```{{exec}}