import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import { Button } from "@/components/atoms/Button";

const meta: Meta<typeof Button> = {
  title: "Atoms/Button",
  component: Button,
  tags: ["autodocs"],
  argTypes: {
    variant: {
      control: "select",
      options: ["primary", "secondary", "ghost", "outline"],
    },
    size: {
      control: "select",
      options: ["sm", "md", "lg"],
    },
    disabled: { control: "boolean" },
  },
};

export default meta;
type Story = StoryObj<typeof Button>;

export const Primary: Story = {
  args: { children: "プライマリ", variant: "primary" },
};

export const Secondary: Story = {
  args: { children: "セカンダリ", variant: "secondary" },
};

export const Outline: Story = {
  args: { children: "アウトライン", variant: "outline" },
};

export const Ghost: Story = {
  args: { children: "ゴースト", variant: "ghost" },
};

export const Small: Story = {
  args: { children: "小さい", size: "sm" },
};

export const Large: Story = {
  args: { children: "大きい", size: "lg" },
};

export const Disabled: Story = {
  args: { children: "無効", disabled: true },
};

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-wrap items-center gap-3">
      <Button variant="primary">プライマリ</Button>
      <Button variant="secondary">セカンダリ</Button>
      <Button variant="outline">アウトライン</Button>
      <Button variant="ghost">ゴースト</Button>
    </div>
  ),
};
