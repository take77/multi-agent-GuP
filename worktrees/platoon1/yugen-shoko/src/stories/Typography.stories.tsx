import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import { Typography } from "@/components/atoms/Typography";

const meta: Meta<typeof Typography> = {
  title: "Atoms/Typography",
  component: Typography,
  tags: ["autodocs"],
  argTypes: {
    variant: {
      control: "select",
      options: ["h1", "h2", "h3", "h4", "body", "bodySmall", "caption"],
    },
  },
};

export default meta;
type Story = StoryObj<typeof Typography>;

export const Heading1: Story = {
  args: { variant: "h1", children: "見出し一 — 和紙の温かみ" },
};

export const Heading2: Story = {
  args: { variant: "h2", children: "見出し二 — 書店の静けさ" },
};

export const Heading3: Story = {
  args: { variant: "h3", children: "見出し三 — 幽玄なる世界" },
};

export const Body: Story = {
  args: {
    variant: "body",
    children:
      "本文テキスト。和紙の温かみと書店の静けさが織りなす、幽玄な読書体験をお届けします。",
  },
};

export const Caption: Story = {
  args: { variant: "caption", children: "キャプション — 2026年1月30日" },
};

export const AllVariants: Story = {
  render: () => (
    <div className="space-y-4">
      <Typography variant="h1">見出し一（Noto Serif JP Bold）</Typography>
      <Typography variant="h2">見出し二（Noto Serif JP Bold）</Typography>
      <Typography variant="h3">見出し三（Noto Serif JP Semi）</Typography>
      <Typography variant="h4">見出し四（Noto Serif JP Semi）</Typography>
      <hr className="border-border" />
      <Typography variant="body">本文（Noto Sans JP Regular）</Typography>
      <Typography variant="bodySmall">小本文（Noto Sans JP Regular）</Typography>
      <Typography variant="caption">キャプション（Noto Sans JP）</Typography>
    </div>
  ),
};
