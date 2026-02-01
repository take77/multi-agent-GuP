"use client";

import { Button } from "@/components/atoms/Button";
import { Badge } from "@/components/atoms/Badge";
import { Typography } from "@/components/atoms/Typography";
import { ThemeToggle } from "@/components/atoms/ThemeToggle";
import { Card, CardHeader, CardContent, CardFooter } from "@/components/molecules/Card";

export default function DesignSystemPage() {
  return (
    <main className="min-h-screen bg-background px-4 py-12 sm:px-8 lg:px-16">
      <div className="mx-auto max-w-4xl space-y-16">
        {/* Header */}
        <header className="flex items-center justify-between">
          <div>
            <Typography variant="h1">幽玄書庫</Typography>
            <Typography variant="bodySmall" className="mt-2 text-muted-foreground">
              Ethereal Library — Design System
            </Typography>
          </div>
          <ThemeToggle />
        </header>

        {/* Typography */}
        <section className="space-y-6">
          <Typography variant="h2">書体</Typography>
          <div className="space-y-4 rounded-xl border border-border bg-card p-8">
            <Typography variant="h1">見出し一 — 和紙の温かみ</Typography>
            <Typography variant="h2">見出し二 — 書店の静けさ</Typography>
            <Typography variant="h3">見出し三 — 幽玄なる世界</Typography>
            <Typography variant="h4">見出し四 — 物語の入り口</Typography>
            <hr className="border-border" />
            <Typography variant="body">
              本文テキスト。和紙の温かみと書店の静けさが織りなす、幽玄な読書体験をお届けします。
              font-feature-settings による和文組版の最適化で、美しい日本語表示を実現しています。
            </Typography>
            <Typography variant="bodySmall">
              小さな本文テキスト。補足情報やメタデータの表示に使用します。
            </Typography>
            <Typography variant="caption">キャプション — 2026年1月30日</Typography>
          </div>
        </section>

        {/* Colors */}
        <section className="space-y-6">
          <Typography variant="h2">色彩</Typography>
          <div className="grid grid-cols-2 gap-4 sm:grid-cols-4">
            <div className="space-y-2">
              <div className="h-20 rounded-lg bg-accent" />
              <Typography variant="caption">アクセント</Typography>
            </div>
            <div className="space-y-2">
              <div className="h-20 rounded-lg bg-sub" />
              <Typography variant="caption">サブ</Typography>
            </div>
            <div className="space-y-2">
              <div className="h-20 rounded-lg bg-muted" />
              <Typography variant="caption">ミュート</Typography>
            </div>
            <div className="space-y-2">
              <div className="h-20 rounded-lg border border-border bg-card" />
              <Typography variant="caption">カード</Typography>
            </div>
          </div>
        </section>

        {/* Buttons */}
        <section className="space-y-6">
          <Typography variant="h2">ボタン</Typography>
          <div className="space-y-4 rounded-xl border border-border bg-card p-8">
            <div className="flex flex-wrap items-center gap-3">
              <Button variant="primary">プライマリ</Button>
              <Button variant="secondary">セカンダリ</Button>
              <Button variant="outline">アウトライン</Button>
              <Button variant="ghost">ゴースト</Button>
            </div>
            <div className="flex flex-wrap items-center gap-3">
              <Button size="sm">小さい</Button>
              <Button size="md">標準</Button>
              <Button size="lg">大きい</Button>
            </div>
            <div className="flex flex-wrap items-center gap-3">
              <Button disabled>無効</Button>
            </div>
          </div>
        </section>

        {/* Badges */}
        <section className="space-y-6">
          <Typography variant="h2">バッジ</Typography>
          <div className="flex flex-wrap items-center gap-3 rounded-xl border border-border bg-card p-8">
            <Badge>デフォルト</Badge>
            <Badge variant="accent">アクセント</Badge>
            <Badge variant="sub">サブ</Badge>
            <Badge variant="outline">アウトライン</Badge>
          </div>
        </section>

        {/* Cards */}
        <section className="space-y-6">
          <Typography variant="h2">カード</Typography>
          <div className="grid gap-6 sm:grid-cols-2">
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
                <div className="flex gap-2">
                  <Badge variant="accent">小説</Badge>
                  <Badge>明治文学</Badge>
                </div>
              </CardFooter>
            </Card>
            <Card hoverable>
              <CardHeader>
                <Typography variant="h4">羅生門</Typography>
                <Typography variant="caption">芥川龍之介</Typography>
              </CardHeader>
              <CardContent>
                <Typography variant="bodySmall">
                  ある日の暮方の事である。一人の下人が、羅生門の下で雨やみを待っていた。
                </Typography>
              </CardContent>
              <CardFooter>
                <div className="flex gap-2">
                  <Badge variant="sub">短編</Badge>
                  <Badge>大正文学</Badge>
                </div>
              </CardFooter>
            </Card>
          </div>
        </section>

        {/* Footer */}
        <footer className="border-t border-border pt-8 text-center">
          <Typography variant="caption">
            幽玄書庫 Design System v0.1.0 — Phase 1
          </Typography>
        </footer>
      </div>
    </main>
  );
}
