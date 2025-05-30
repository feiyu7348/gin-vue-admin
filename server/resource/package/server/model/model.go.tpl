{{- if .IsAdd}}
// 在结构体中新增如下字段
{{- range .Fields}}
  {{ GenerateField . }}
{{- end }}

{{ else }}
// 自动生成模板{{.StructName}}
package {{.Package}}

{{- if not .OnlyTemplate}}
import (
	{{- if .GvaModel }}
	"{{.Module}}/global"
	{{- end }}
	{{- if or .HasTimer }}
	"time"
	{{- end }}
	{{- if .NeedJSON }}
	"gorm.io/datatypes"
	{{- end }}
)
{{- end }}

// {{.Description}} 结构体  {{.StructName}}
type {{.StructName}} struct {
{{- if not .OnlyTemplate}}
{{- if .GvaModel }}
    global.GVA_MODEL
{{- end }}
{{- range .Fields}}
  {{ GenerateField . }}
{{- end }}
    {{- if .AutoCreateResource }}
    CreatedBy  uint   `gorm:"column:created_by;comment:创建者"`
    UpdatedBy  uint   `gorm:"column:updated_by;comment:更新者"`
    DeletedBy  uint   `gorm:"column:deleted_by;comment:删除者"`
    {{- end }}
    {{- if .IsTree }}
    Children   []*{{.StructName}} `json:"children" gorm:"-"`     //子节点
    ParentID   int             `json:"parentID" gorm:"column:parent_id;comment:父节点"`
    {{- end }}
{{- end }}
}

{{ if .TableName }}
// TableName {{.Description}} {{.StructName}}自定义表名 {{.TableName}}
func ({{.StructName}}) TableName() string {
    return "{{.TableName}}"
}
{{ end }}

{{if .IsTree }}
// GetChildren 实现TreeNode接口
func (s *{{.StructName}}) GetChildren() []*{{.StructName}} {
    return s.Children
}

// SetChildren 实现TreeNode接口
func (s *{{.StructName}}) SetChildren(children *{{.StructName}}) {
	s.Children = append(s.Children, children)
}

// GetID 实现TreeNode接口
func (s *{{.StructName}}) GetID() int {
    return int({{if not .GvaModel}}*{{- end }}s.{{.PrimaryField.FieldName}})
}

// GetParentID 实现TreeNode接口
func (s *{{.StructName}}) GetParentID() int {
    return s.ParentID
}
{{ end }}

{{ end }}
