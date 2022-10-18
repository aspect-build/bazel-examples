import { fireEvent, render, screen } from '@testing-library/react';
import CheckboxWithLabel from './CheckboxWithLabel';
import '@testing-library/jest-dom/extend-expect';

it('CheckboxWithLabel changes the text after click', () => {
  const { queryByLabelText, getByLabelText } = render(
    <CheckboxWithLabel labelOn="On" labelOff="Off" />
  );

  expect(screen.getByText(/off/i)).toBeInTheDocument();

  expect(queryByLabelText(/off/i)).toBeTruthy();

  fireEvent.click(getByLabelText(/off/i));

  expect(queryByLabelText(/on/i)).toBeTruthy();
});
