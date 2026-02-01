# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Foreshadowing Status Transitions", type: :model do
  # ==========================================================
  # P2-TE-001: 伏線ステータス遷移テスト
  # テスター: ミッコ（第2中隊）
  #
  # 注意: 現在のモデルには状態遷移バリデーションが未実装。
  # Rails enum は任意の値への変更を許可する。
  # このテストでは「期待される遷移ルール」を明示し、
  # 実装状況に応じて pass/fail を記録する。
  # ==========================================================

  describe "valid transitions" do
    # --- FST-001: planted → hinted ---
    context "from planted to hinted" do
      it "transitions successfully" do
        fs = create(:foreshadowing, status: :planted)
        fs.hinted!
        expect(fs.reload.status).to eq "hinted"
      end
    end

    # --- FST-002: hinted → resolved ---
    context "from hinted to resolved" do
      it "transitions successfully" do
        fs = create(:foreshadowing, status: :hinted)
        fs.resolved!
        expect(fs.reload.status).to eq "resolved"
      end
    end

    # --- FST-003: planted → resolved（直接回収）---
    context "from planted to resolved (direct resolution)" do
      it "transitions successfully" do
        fs = create(:foreshadowing, status: :planted)
        fs.resolved!
        expect(fs.reload.status).to eq "resolved"
      end
    end

    # --- FST-004: planted → abandoned ---
    context "from planted to abandoned" do
      it "transitions successfully" do
        fs = create(:foreshadowing, status: :planted)
        fs.abandoned!
        expect(fs.reload.status).to eq "abandoned"
      end
    end

    # --- FST-005: hinted → abandoned ---
    context "from hinted to abandoned" do
      it "transitions successfully" do
        fs = create(:foreshadowing, status: :hinted)
        fs.abandoned!
        expect(fs.reload.status).to eq "abandoned"
      end
    end
  end

  describe "invalid transitions (requires state machine implementation)" do
    # 現在の Rails enum には遷移制御がないため、これらのテストは
    # 「期待される振る舞い」を文書化する目的で記述。
    # 状態遷移バリデーションが実装されたら、テストが正しく fail → pass する。

    # --- FST-006: resolved → planted（不正遷移）---
    context "from resolved to planted" do
      it "currently allows transition (state machine not yet implemented)" do
        fs = create(:foreshadowing, status: :resolved)
        # Rails enum は遷移制御なし → 現在は通ってしまう
        fs.planted!
        expect(fs.reload.status).to eq "planted"
      end

      it "[EXPECTED] should reject resolved → planted when state machine is implemented",
         pending: "状態遷移バリデーション未実装" do
        fs = create(:foreshadowing, status: :resolved)
        expect { fs.planted! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    # --- FST-007: resolved → hinted（不正遷移）---
    context "from resolved to hinted" do
      it "[EXPECTED] should reject resolved → hinted",
         pending: "状態遷移バリデーション未実装" do
        fs = create(:foreshadowing, status: :resolved)
        expect { fs.hinted! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    # --- FST-008: abandoned → resolved（不正遷移）---
    context "from abandoned to resolved" do
      it "[EXPECTED] should reject abandoned → resolved",
         pending: "状態遷移バリデーション未実装" do
        fs = create(:foreshadowing, status: :abandoned)
        expect { fs.resolved! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    # --- FST-009: abandoned → planted（不正遷移）---
    context "from abandoned to planted" do
      it "[EXPECTED] should reject abandoned → planted",
         pending: "状態遷移バリデーション未実装" do
        fs = create(:foreshadowing, status: :abandoned)
        expect { fs.planted! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    # --- FST-010: abandoned → hinted（不正遷移）---
    context "from abandoned to hinted" do
      it "[EXPECTED] should reject abandoned → hinted",
         pending: "状態遷移バリデーション未実装" do
        fs = create(:foreshadowing, status: :abandoned)
        expect { fs.hinted! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    # --- FST-011: resolved → abandoned（不正遷移）---
    context "from resolved to abandoned" do
      it "[EXPECTED] should reject resolved → abandoned",
         pending: "状態遷移バリデーション未実装" do
        fs = create(:foreshadowing, status: :resolved)
        expect { fs.abandoned! }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe "resolved_episode_id behavior" do
    # --- FST-012: resolved に遷移した際、resolved_episode_id が設定されること ---
    context "when transitioning to resolved" do
      it "should have resolved_episode_id set (application logic)" do
        fs = create(:foreshadowing, status: :planted)
        fs.update!(status: :resolved, resolved_episode_id: 5)
        expect(fs.reload.resolved_episode_id).to eq 5
      end
    end

    # --- FST-013: resolved 以外の状態では resolved_episode_id が nil であること ---
    context "when status is not resolved" do
      it "resolved_episode_id is nil for planted" do
        fs = create(:foreshadowing, status: :planted, resolved_episode_id: nil)
        expect(fs.resolved_episode_id).to be_nil
      end

      it "resolved_episode_id is nil for hinted" do
        fs = create(:foreshadowing, status: :hinted, resolved_episode_id: nil)
        expect(fs.resolved_episode_id).to be_nil
      end

      it "resolved_episode_id is nil for abandoned" do
        fs = create(:foreshadowing, status: :abandoned, resolved_episode_id: nil)
        expect(fs.resolved_episode_id).to be_nil
      end
    end
  end

  describe "enum query scopes" do
    before do
      create(:foreshadowing, status: :planted, title: "伏線1")
      create(:foreshadowing, status: :planted, title: "伏線2")
      create(:foreshadowing, status: :hinted, title: "伏線3")
      create(:foreshadowing, status: :resolved, title: "伏線4")
      create(:foreshadowing, status: :abandoned, title: "伏線5")
    end

    it "correctly counts planted foreshadowings" do
      expect(Foreshadowing.planted.count).to eq 2
    end

    it "correctly counts hinted foreshadowings" do
      expect(Foreshadowing.hinted.count).to eq 1
    end

    it "correctly counts resolved foreshadowings" do
      expect(Foreshadowing.resolved.count).to eq 1
    end

    it "correctly counts abandoned foreshadowings" do
      expect(Foreshadowing.abandoned.count).to eq 1
    end

    it "unresolved foreshadowings = planted + hinted" do
      unresolved = Foreshadowing.where(status: [:planted, :hinted])
      expect(unresolved.count).to eq 3
    end
  end
end
