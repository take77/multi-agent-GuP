import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import { Badge } from "@/components/atoms/Badge";

const meta: Meta<typeof Badge> = {
  title: "Atoms/Badge",
  component: Badge,
  tags: ["autodocs"],
  argTypes: {
    variant: {
      control: "select",
      options: ["default", "accent", "sub", "outline"],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Badge>;

export const Default: Story = {
  args: { children: "デフォルト" },
};

export const Accent: Story = {
  args: { children: "アクセント", variant: "accent" },
};

export const Sub: Story = {
  args: { children: "サブ", variant: "sub" },
};

export const Outline: Story = {
  args: { children: "アウトライン", variant: "outline" },
};

export const AllVariants: Story = {
  render: () => (
    <div className="flex flex-wrap items-center gap-3">
      <Badge>デフォルト</Badge>
      <Badge variant="accent">小説</Badge>
      <Badge variant="sub">短編</Badge>
      <Badge variant="outline">明治文学</Badge>
    </div>
  ),
};
