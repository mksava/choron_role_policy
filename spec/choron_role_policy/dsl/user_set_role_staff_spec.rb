RSpec.describe ChoronRolePolicy::DSL do
  describe ".set_role" do
    let!(:user) { build(:user, staff_role: staff_role) }
    context "(ユーザの権限がadminのとき)" do
      let!(:staff_role) { "admin" }
      describe "#comment_operate?" do
        # テストの期待値は設定ファイル(config/choron_role_policy/staff.yml)に合わせています
        where(:policy_types, :expected) do
          [
            [nil, false],
            [:full, false],
            [:create, true],
            [:update, true],
            [[:create, :update], true],
            [:delete, false],
            [[:create, :delete], false],
          ]
        end
        with_them do
          it "設定値通りにtrue/falseが返ること" do
            result = user.staff.comment_operate?(*policy_types)
            expect(result).to eq(expected)
          end
        end

        context "(存在しないポリシータイプを指定したとき)" do
          it "エラーが発生すること" do
            expect { user.staff.comment_operate?(:invalid) }.to raise_error(ArgumentError, "Policy type not found in [comment_operate]. policy_type: invalid")
          end
        end

        context "(all_allowに渡したメソッドがtrueを返すとき)" do
          before { allow(user).to receive(:is_super?).and_return(true) }
          it "どの結果もtrueになること" do
            aggregate_failures do
              expect(user.staff.comment_operate?).to eq(true)
              expect(user.staff.comment_operate?(:full)).to eq(true)
              expect(user.staff.comment_operate?(:create)).to eq(true)
              expect(user.staff.comment_operate?(:create, :destroy)).to eq(true)
            end
          end
        end
      end

      describe "#company_operate?" do
        # テストの期待値は設定ファイル(config/choron_role_policy/staff.yml)に合わせています
        where(:policy_types, :expected) do
          [
            [nil, true],
            [:full, true],
            [:create, true],
            [:update, true],
            [[:create, :update], true],
            [:delete, true],
            [[:create, :delete], true],
          ]
        end
        with_them do
          it "設定値通りにtrue/falseが返ること" do
            result = user.staff.company_operate?(*policy_types)
            expect(result).to eq(expected)
          end
        end
      end

      describe "#foo_operate?" do
        it "存在しない定義なのでエラーが返ること" do
          expect { user.staff.foo_operate? }.to raise_error(NoMethodError, "[Important!] The methods of this object are defined by spec/rails/config/choron_role_policy/policy.yml. Check the configuration file to see if foo_operate is set.")
        end
      end
    end
  end
end