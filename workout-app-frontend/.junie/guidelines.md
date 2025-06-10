# TypeScript React Project Guidelines

This document outlines best practices and guidelines for developing web applications using TypeScript and React. Following these guidelines will help maintain code quality, consistency, and developer productivity.

## Table of Contents
- [Project Structure](#project-structure)
- [TypeScript Best Practices](#typescript-best-practices)
- [React Component Patterns](#react-component-patterns)
- [State Management](#state-management)
- [Styling Approaches](#styling-approaches)
- [Testing](#testing)
- [Performance Optimization](#performance-optimization)
- [Code Quality and Linting](#code-quality-and-linting)
- [Build and Deployment](#build-and-deployment)

## Project Structure

The project follows a feature-based organization:

```
src/
├── assets/           # Static assets (images, fonts, etc.)
├── components/       # Reusable UI components
├── types/            # TypeScript type definitions
├── hooks/            # Custom React hooks
├── utils/            # Utility functions
├── services/         # API services and data fetching
├── context/          # React context providers
├── pages/            # Page components (for routing)
├── App.tsx           # Main application component
├── main.tsx          # Application entry point
└── index.css         # Global styles
```

### Guidelines:

- Keep components small and focused on a single responsibility
- Group related files together (e.g., component and its styles)
- Use index files to simplify imports
- Create dedicated directories for different concerns (hooks, utils, etc.)

## TypeScript Best Practices

### Type Definitions

- Define interfaces and types in dedicated files under the `types/` directory
- Use interfaces for object shapes that might be extended
- Use type aliases for unions, intersections, and simpler types
- Prefer explicit typing over `any` or implicit typing
- Use TypeScript's utility types when appropriate (Partial, Pick, Omit, etc.)

```typescript
// Good
interface User {
  id: string;
  name: string;
  email: string;
}

type UserRole = 'admin' | 'user' | 'guest';

// Bad
const user: any = { id: '1', name: 'John' };
```

### Type Safety

- Enable strict mode in TypeScript configuration
- Avoid type assertions (`as`) when possible
- Use proper typing for React event handlers
- Define return types for functions, especially for complex functions

```typescript
// Good
function calculateTotal(items: CartItem[]): number {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}

// Bad
function calculateTotal(items) {
  return items.reduce((sum, item) => sum + item.price * item.quantity, 0);
}
```

## React Component Patterns

### Functional Components

- Use functional components with hooks instead of class components
- Use proper TypeScript typing for props and state
- Destructure props for better readability
- Provide default values for optional props

```typescript
interface ButtonProps {
  label: string;
  onClick: () => void;
  variant?: 'primary' | 'secondary';
  disabled?: boolean;
}

const Button: React.FC<ButtonProps> = ({ 
  label, 
  onClick, 
  variant = 'primary', 
  disabled = false 
}) => {
  return (
    <button 
      className={`button ${variant}`} 
      onClick={onClick} 
      disabled={disabled}
    >
      {label}
    </button>
  );
};
```

### Component Organization

- Keep components small and focused
- Extract complex logic into custom hooks
- Use composition over inheritance
- Split large components into smaller, reusable pieces

### Props

- Use TypeScript interfaces to define prop types
- Make props immutable (treat them as read-only)
- Provide sensible default values for optional props
- Use prop destructuring for cleaner code

## State Management

### Local State

- Use `useState` for simple component state
- Use `useReducer` for complex state logic
- Keep state as close as possible to where it's used

```typescript
const [isOpen, setIsOpen] = useState<boolean>(false);
```

### Context API

- Use Context API for state that needs to be accessed by many components
- Create dedicated context providers for different domains
- Keep context values focused on a specific concern

```typescript
const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: React.FC<PropsWithChildren> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);

  // Auth logic here

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
};
```

### External State Management

For larger applications, consider using:
- Redux Toolkit (for complex global state)
- Zustand (for simpler global state)
- React Query (for server state)

## Styling Approaches

### CSS Modules

- Use CSS Modules for component-specific styles
- Name CSS files to match their component (e.g., `Button.module.css`)
- Use semantic class names based on purpose, not appearance

```typescript
import styles from './Button.module.css';

const Button = () => {
  return <button className={styles.button}>Click me</button>;
};
```

### Styled Components

If using styled-components:
- Create styled components in separate files or at the top of component files
- Use TypeScript with styled-components for better type safety
- Use theme provider for consistent styling

### CSS Variables

- Use CSS variables for theming and consistent values
- Define global variables in a central location

## Testing

### Testing Libraries

- Jest for unit and integration testing
- React Testing Library for component testing
- Cypress for end-to-end testing

### Testing Guidelines

- Write tests for critical business logic
- Test component behavior, not implementation details
- Use meaningful test descriptions
- Follow the Arrange-Act-Assert pattern

```typescript
test('should add a new item when the form is submitted', () => {
  // Arrange
  render(<TodoForm onSubmit={mockSubmit} />);

  // Act
  fireEvent.change(screen.getByLabelText('Task'), { target: { value: 'New task' } });
  fireEvent.click(screen.getByText('Add'));

  // Assert
  expect(mockSubmit).toHaveBeenCalledWith({ text: 'New task', completed: false });
});
```

## Performance Optimization

### Memoization

- Use `React.memo` for components that render often with the same props
- Use `useMemo` for expensive calculations
- Use `useCallback` for functions passed as props to memoized components

```typescript
const memoizedValue = useMemo(() => computeExpensiveValue(a, b), [a, b]);

const memoizedCallback = useCallback(() => {
  doSomething(a, b);
}, [a, b]);
```

### Rendering Optimization

- Avoid unnecessary re-renders
- Keep component state as local as possible
- Use virtualization for long lists (react-window or react-virtualized)
- Use code splitting and lazy loading for large components

```typescript
const LazyComponent = React.lazy(() => import('./LazyComponent'));

function App() {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <LazyComponent />
    </Suspense>
  );
}
```

## Code Quality and Linting

### ESLint

- Use ESLint with TypeScript support
- Extend recommended configs for React and TypeScript
- Add custom rules as needed for project-specific requirements

### Prettier

- Use Prettier for consistent code formatting
- Configure Prettier to work with ESLint
- Use a pre-commit hook to format code automatically

### Code Reviews

- Review code for readability, maintainability, and performance
- Check for proper TypeScript usage
- Ensure components follow established patterns
- Verify that tests cover critical functionality

## Build and Deployment

### Build Process

- Use Vite for fast development and optimized production builds
- Run TypeScript type checking before builds
- Optimize assets during build

```bash
# Development
npm run dev

# Production build
npm run build
```

### Deployment

- Use continuous integration for automated testing
- Deploy to staging environments before production
- Use environment variables for configuration
- Implement proper error monitoring in production

---

These guidelines are meant to be a living document. As the project evolves and new best practices emerge, this document should be updated accordingly.
