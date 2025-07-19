import React from 'react';
import { TextInput as RNTextInput, StyleSheet, Text, View } from 'react-native';
import { TextInput as PaperInput, useTheme } from 'react-native-paper';

type FormInputProps = React.ComponentProps<typeof PaperInput> & {
  label: string;
  error?: string;
  touched?: boolean;
  showEyeIcon?: boolean;
  onTogglePasswordVisibility?: () => void;
};

export const FormInput = ({
  label,
  error,
  touched,
  showEyeIcon = false,
  onTogglePasswordVisibility,
  ...props
}: FormInputProps) => {
  const theme = useTheme();
  const showError = error && touched;

  return (
    <View style={styles.container}>
      <PaperInput
        label={label}
        mode="outlined"
        error={showError}
        style={styles.input}
        outlineColor={showError ? theme.colors.error : theme.colors.outline}
        activeOutlineColor={showError ? theme.colors.error : theme.colors.primary}
        right={
          showEyeIcon ? (
            <PaperInput.Icon
              icon={props.secureTextEntry ? 'eye' : 'eye-off'}
              onPress={onTogglePasswordVisibility}
              forceTextInputFocus={false}
            />
          ) : null
        }
        {...props}
      />
      {showError && (
        <Text style={[styles.errorText, { color: theme.colors.error }]}>
          {error}
        </Text>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  input: {
    backgroundColor: 'transparent',
  },
  errorText: {
    marginTop: 4,
    fontSize: 12,
  },
});
