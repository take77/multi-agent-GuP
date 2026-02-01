import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import { Card, CardHeader, CardContent, CardFooter } from "@/components/molecules/Card";
import { Typography } from "@/components/atoms/Typography";
import { Badge } from "@/components/atoms/Badge";
import { Button } from "@/components/atoms/Button";

const meta: Meta<typeof Card> = {
  title: "Molecules/Card",
  component: Card,
  tags: ["autodocs"],
  argTypes: {
    hoverable: { control: "boolean" },
  },
};

export default meta;
type Story = StoryObj<typeof Card>;

export const Default: Story = {
  render: (args) => (
    <Card {...args}>
      <CardContent>
        <Typography variant="body">シンプルなカードコンテンツ</Typography>
      </CardContent>
    </Card>
  ),
};

export const WithHeader: Story = {
  render: (args) => (
    <Card {...args}>
      <CardHeader>
        <Typography variant="h4">カードタイトル</Typography>
        <Typography variant="caption">サブタイトル</Typography>
      </CardHeader>
      <CardContent>
        <Typography variant="bodySmall">
          カードのコンテンツエリアです。
        </Typography>
      </CardContent>
    </Card>
  ),
};

export const BookCard: Story = {
  render: () => (
    <div className="max-w-sm">
      <Card hoverable>
        <CardHeader>
          <Typography variant="h4">吾輩は猫である</Typography>
          <Typography variant="caption">夏目漱石</Typography>
        </CardHeader>
        <CardContent>
          <Typography variant="bodySmall">
            吾輩は猫である。名前はまだ無い。どこで生まれたかとんと見当がつかぬ。
          </Typography>
        </CardContent>
        <CardFooter>
          <div className="flex items-center justify-between">
            <div className="flex gap-2">
              <Badge variant="accent">小説</Badge>
              <Badge>明治文学</Badge>
            </div>
            <Button size="sm" variant="ghost">
              詳細
            </Button>
          </div>
        </CardFooter>
      </Card>
    </div>
  ),
};

export const Hoverable: Story = {
  args: { hoverable: true },
  render: (args) => (
    <Card {...args}>
      <CardContent>
        <Typography variant="body">ホバーで浮き上がるカード</Typography>
      </CardContent>
    </Card>
  ),
};
