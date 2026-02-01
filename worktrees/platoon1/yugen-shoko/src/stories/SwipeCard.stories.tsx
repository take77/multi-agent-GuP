import type { Meta, StoryObj } from "@storybook/nextjs-vite";
import { SwipeCard } from "@/components/organisms/SwipeCard";
import { Badge } from "@/components/atoms/Badge";
import { Typography } from "@/components/atoms/Typography";
const meta = {
  title: "Organisms/SwipeCard",
  component: SwipeCard,
  parameters: {
    layout: "centered",
    docs: {
      description: {
        component:
          "Tinder風スワイプカード。右スワイプでお気に入り、左スワイプでスキップ、ダブルタップですぐ読む。",
      },
    },
  },
  decorators: [
    (Story) => (
      <div style={{ width: 327, height: 480 }}>
        <Story />
      </div>
    ),
  ],
} satisfies Meta<typeof SwipeCard>;

export default meta;
type Story = StoryObj<typeof meta>;

const NovelCardContent = () => (
  <div className="flex h-full flex-col">
    {/* Cover */}
    <div className="flex h-56 items-center justify-center bg-muted">
      <Typography variant="caption">カバーイメージ</Typography>
    </div>
    {/* Content */}
    <div className="flex flex-1 flex-col gap-2 p-5">
      <Typography variant="h3">蒼穹の剣聖伝説</Typography>
      <Typography variant="caption">クリエイト &amp; レビュー 著</Typography>
      <div className="flex gap-1.5">
        <Badge>ファンタジー</Badge>
        <Badge variant="accent">冒険</Badge>
      </div>
      <Typography variant="bodySmall" className="mt-1 line-clamp-3">
        天空の浮遊城に封印された古代の剣。若き剣士レイドは、師匠の遺言に導かれ果てなき旅路へと踏み出す...
      </Typography>
      <div className="mt-auto flex items-center justify-between">
        <Typography variant="caption">全42話 ・ 評価 4.5</Typography>
        <Badge variant="accent">92% マッチ</Badge>
      </div>
    </div>
  </div>
);

export const Default: Story = {
  args: {
    className: "h-full w-full",
    children: <NovelCardContent />,
  },
};

export const NonSwipeable: Story = {
  args: {
    className: "h-full w-full",
    swipeable: false,
    children: <NovelCardContent />,
  },
};

export const CustomThreshold: Story = {
  args: {
    className: "h-full w-full",
    swipeThreshold: 50,
    children: <NovelCardContent />,
  },
};
