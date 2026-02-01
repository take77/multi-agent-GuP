import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import { ThemeToggle } from "@/components/atoms/ThemeToggle";

const meta: Meta<typeof ThemeToggle> = {
  title: "Atoms/ThemeToggle",
  component: ThemeToggle,
  tags: ["autodocs"],
};

export default meta;
type Story = StoryObj<typeof ThemeToggle>;

export const Default: Story = {};
