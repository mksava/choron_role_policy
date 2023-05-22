# ChoronRolePolicy

`ChoronRolePolicy` は主に `Rails` の `Model` から利用されることを想定した認可の仕組みです。
以下の特徴を持っています。

1. 設定ファイル（yml）だけを操作するだけで認可の設定を簡易に作成・更新することができる
2. AWSのPolicyとRoleの考え方を基本としている

## インストール

```
$ bundle add choron_role_policy
```

```
$ gem install choron_role_policy
```

## 使い方

### Railsからの利用

インストール後、 `config/initializers` に `choron_role_policy.rb` を作成してください。

```ruby
ChoronRolePolicy.load
```

後述する設定ファイルの置き場所を変更したいときは以下のように変更することが可能です。

```ruby
ChoronRolePolicy.load do |config|
  config.policy_file = "xxxx/yyyyy/policy.yml"
  config.role_root = "xxxx/yyyyy/"
end
```

その後設定ファイルを配置してください。上記で変更をしているときは変更後のディレクトリ、もし何もしていなければデフォルトのディレクトリに配置をしてください。

以下はデフォルトのときの配置例です。

* config/choron_role_policy/policy.yml

以下のように認可が必要な操作を列挙していってください

```yml
company_operate:
  - create
  - read
  - update
  - destroy
user_operate:
  - read
  - destroy
```

* config/choron_role_policy/staff.yml

* 以下を参考に役割ごとにできる操作を定義してください

```yml
# スタッフのOwner権限はフル(全て許可)される
owner:
  company_operate: full
  user_operate: full
# スタッフのAdmin権限
admin:
  # 企業データは閲覧と更新が可能
  company_operate:
    - read
    - update
  # ユーザデータは閲覧のみ可能
  user_operate:
    - read
# スタッフのMember権限
member:
  # 企業データは閲覧だけ可能
  company_operate:
    - read
  # ユーザデータは権限なし
```

その後、これらの認可を行いたいモデルに本GemのModuleを読み込ませて、設定を行ってください

```ruby
# ユーザには staff_role という役割を示すDBのカラムを持っていることが前提です
# staff_role :integer, default: 0
class User < ApplicationRecord
  include ChoronRolePolicy::DSL

  # Railsのenumで定義。0が権限なし、1でmember, 2でadmin...
  enum :staff, [:none, :member, :admin, :owner], prefix: true
  # :staff というタイプを渡しているとき staff_role というカラム名をデフォルトで参照するため、その他の設定は不要
  set_role :staff
end
```

この設定が行った後、ControllerやModelで以下の利用に利用可能です。

```ruby
class FooController < ApplicationController
  def show
    # 企業操作のフルアクセスを持っているとき
    if current_user.staff.company_operate?
      # ...
    end

    # ユーザ操作の読み取り権限を持っているとき
    if current_user.staff.user_operate?(:read)
    end
  end
end
```

## License

[MIT License](https://opensource.org/licenses/MIT).