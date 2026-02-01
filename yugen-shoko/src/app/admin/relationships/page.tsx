"use client";

import React, { useCallback } from "react";
import dynamic from "next/dynamic";
import { useRelationshipGraph } from "@/features/relationships/hooks/useRelationships";
import { ListLayout } from "@/layouts";
import { Card, CardContent, Modal, ModalBody } from "@/components/molecules";
import type { CharacterRelationship } from "@/lib/api";

// react-force-graph-2d はSSR非対応のため dynamic import
const ForceGraph2D = dynamic(
  () => import("react-force-graph-2d").then((mod) => mod.default ?? mod),
  {
    ssr: false,
    loading: () => (
      <div className="flex items-center justify-center h-[500px] text-muted-foreground">
        グラフを読み込み中...
      </div>
    ),
  }
) as React.ComponentType<Record<string, unknown>>;

export default function RelationshipsPage() {
  const { graphData, relationships, loading, error, selected, setSelected } =
    useRelationshipGraph();

  const handleLinkClick = useCallback(
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (link: any) => {
      const rel = relationships.find((r) => r.id === link.relationshipId);
      if (rel) setSelected(rel);
    },
    [relationships, setSelected]
  );

  return (
    <ListLayout
      title="キャラクター関係性"
      description="キャラクター間の関係性をグラフで可視化します"
    >
      {loading && (
        <p className="text-muted-foreground py-8 text-center">読み込み中...</p>
      )}
      {error && (
        <p className="text-red-400 py-8 text-center">{error}</p>
      )}
      {!loading && !error && graphData.nodes.length === 0 && (
        <p className="text-muted-foreground py-8 text-center">
          キャラクターが登録されていません
        </p>
      )}
      {!loading && !error && graphData.nodes.length > 0 && (
        <Card>
          <CardContent className="p-0 overflow-hidden rounded-xl">
            <ForceGraph2D
              graphData={graphData}
              width={900}
              height={500}
              nodeLabel="name"
              nodeColor={() => "hsl(var(--accent))"}
              nodeRelSize={8}
              nodeCanvasObjectMode={() => "after"}
              nodeCanvasObject={(node: any, ctx: CanvasRenderingContext2D, globalScale: number) => {
                const label = (node.name as string) ?? "";
                const fontSize = 12 / globalScale;
                ctx.font = `${fontSize}px 'Noto Sans JP', sans-serif`;
                ctx.fillStyle = "hsl(var(--foreground))";
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                ctx.fillText(label, node.x as number, (node.y as number) + 12);
              }}
              linkWidth={(link: any) => ((link.intensity as number) ?? 5) / 2}
              linkColor={() => "hsl(var(--border))"}
              linkLabel={(link: any) => (link.label as string) ?? ""}
              onLinkClick={handleLinkClick}
              backgroundColor="transparent"
            />
          </CardContent>
        </Card>
      )}

      <Modal
        open={!!selected}
        onClose={() => setSelected(null)}
        title="関係性の詳細"
        size="sm"
      >
        {selected && <RelationshipDetail relationship={selected} />}
      </Modal>
    </ListLayout>
  );
}

function RelationshipDetail({ relationship }: { relationship: CharacterRelationship }) {
  return (
    <ModalBody>
      <dl className="space-y-3">
        <div>
          <dt className="text-xs text-muted-foreground">キャラクター</dt>
          <dd className="font-medium">
            {relationship.character.name} → {relationship.related_character.name}
          </dd>
        </div>
        <div>
          <dt className="text-xs text-muted-foreground">関係性タイプ</dt>
          <dd>{relationship.relationship_type}</dd>
        </div>
        {relationship.intensity != null && (
          <div>
            <dt className="text-xs text-muted-foreground">強度</dt>
            <dd>{relationship.intensity} / 10</dd>
          </div>
        )}
        {relationship.description && (
          <div>
            <dt className="text-xs text-muted-foreground">説明</dt>
            <dd className="whitespace-pre-wrap">{relationship.description}</dd>
          </div>
        )}
      </dl>
    </ModalBody>
  );
}
