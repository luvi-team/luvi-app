export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "13.0.4"
  }
  public: {
    Tables: {
      archon_code_examples: {
        Row: {
          chunk_number: number
          content: string
          content_search_vector: unknown
          created_at: string
          embedding_1024: string | null
          embedding_1536: string | null
          embedding_3072: string | null
          embedding_384: string | null
          embedding_768: string | null
          embedding_dimension: number | null
          embedding_model: string | null
          id: number
          llm_chat_model: string | null
          metadata: Json
          source_id: string
          summary: string
          url: string
        }
        Insert: {
          chunk_number: number
          content: string
          content_search_vector?: unknown
          created_at?: string
          embedding_1024?: string | null
          embedding_1536?: string | null
          embedding_3072?: string | null
          embedding_384?: string | null
          embedding_768?: string | null
          embedding_dimension?: number | null
          embedding_model?: string | null
          id?: number
          llm_chat_model?: string | null
          metadata?: Json
          source_id: string
          summary: string
          url: string
        }
        Update: {
          chunk_number?: number
          content?: string
          content_search_vector?: unknown
          created_at?: string
          embedding_1024?: string | null
          embedding_1536?: string | null
          embedding_3072?: string | null
          embedding_384?: string | null
          embedding_768?: string | null
          embedding_dimension?: number | null
          embedding_model?: string | null
          id?: number
          llm_chat_model?: string | null
          metadata?: Json
          source_id?: string
          summary?: string
          url?: string
        }
        Relationships: [
          {
            foreignKeyName: "archon_code_examples_source_id_fkey"
            columns: ["source_id"]
            isOneToOne: false
            referencedRelation: "archon_sources"
            referencedColumns: ["source_id"]
          },
        ]
      }
      archon_crawled_pages: {
        Row: {
          chunk_number: number
          content: string
          content_search_vector: unknown
          created_at: string
          embedding_1024: string | null
          embedding_1536: string | null
          embedding_3072: string | null
          embedding_384: string | null
          embedding_768: string | null
          embedding_dimension: number | null
          embedding_model: string | null
          id: number
          llm_chat_model: string | null
          metadata: Json
          page_id: string | null
          source_id: string
          url: string
        }
        Insert: {
          chunk_number: number
          content: string
          content_search_vector?: unknown
          created_at?: string
          embedding_1024?: string | null
          embedding_1536?: string | null
          embedding_3072?: string | null
          embedding_384?: string | null
          embedding_768?: string | null
          embedding_dimension?: number | null
          embedding_model?: string | null
          id?: number
          llm_chat_model?: string | null
          metadata?: Json
          page_id?: string | null
          source_id: string
          url: string
        }
        Update: {
          chunk_number?: number
          content?: string
          content_search_vector?: unknown
          created_at?: string
          embedding_1024?: string | null
          embedding_1536?: string | null
          embedding_3072?: string | null
          embedding_384?: string | null
          embedding_768?: string | null
          embedding_dimension?: number | null
          embedding_model?: string | null
          id?: number
          llm_chat_model?: string | null
          metadata?: Json
          page_id?: string | null
          source_id?: string
          url?: string
        }
        Relationships: [
          {
            foreignKeyName: "archon_crawled_pages_page_id_fkey"
            columns: ["page_id"]
            isOneToOne: false
            referencedRelation: "archon_page_metadata"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "archon_crawled_pages_source_id_fkey"
            columns: ["source_id"]
            isOneToOne: false
            referencedRelation: "archon_sources"
            referencedColumns: ["source_id"]
          },
        ]
      }
      archon_document_versions: {
        Row: {
          change_summary: string | null
          change_type: string | null
          content: Json
          created_at: string | null
          created_by: string | null
          document_id: string | null
          field_name: string
          id: string
          project_id: string | null
          task_id: string | null
          version_number: number
        }
        Insert: {
          change_summary?: string | null
          change_type?: string | null
          content: Json
          created_at?: string | null
          created_by?: string | null
          document_id?: string | null
          field_name: string
          id?: string
          project_id?: string | null
          task_id?: string | null
          version_number: number
        }
        Update: {
          change_summary?: string | null
          change_type?: string | null
          content?: Json
          created_at?: string | null
          created_by?: string | null
          document_id?: string | null
          field_name?: string
          id?: string
          project_id?: string | null
          task_id?: string | null
          version_number?: number
        }
        Relationships: [
          {
            foreignKeyName: "archon_document_versions_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "archon_projects"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "archon_document_versions_task_id_fkey"
            columns: ["task_id"]
            isOneToOne: false
            referencedRelation: "archon_tasks"
            referencedColumns: ["id"]
          },
        ]
      }
      archon_migrations: {
        Row: {
          applied_at: string | null
          checksum: string | null
          id: string
          migration_name: string
          version: string
        }
        Insert: {
          applied_at?: string | null
          checksum?: string | null
          id?: string
          migration_name: string
          version: string
        }
        Update: {
          applied_at?: string | null
          checksum?: string | null
          id?: string
          migration_name?: string
          version?: string
        }
        Relationships: []
      }
      archon_page_metadata: {
        Row: {
          char_count: number
          chunk_count: number
          created_at: string | null
          full_content: string
          id: string
          metadata: Json | null
          section_order: number | null
          section_title: string | null
          source_id: string
          updated_at: string | null
          url: string
          word_count: number
        }
        Insert: {
          char_count: number
          chunk_count?: number
          created_at?: string | null
          full_content: string
          id?: string
          metadata?: Json | null
          section_order?: number | null
          section_title?: string | null
          source_id: string
          updated_at?: string | null
          url: string
          word_count: number
        }
        Update: {
          char_count?: number
          chunk_count?: number
          created_at?: string | null
          full_content?: string
          id?: string
          metadata?: Json | null
          section_order?: number | null
          section_title?: string | null
          source_id?: string
          updated_at?: string | null
          url?: string
          word_count?: number
        }
        Relationships: [
          {
            foreignKeyName: "archon_page_metadata_source_fk"
            columns: ["source_id"]
            isOneToOne: false
            referencedRelation: "archon_sources"
            referencedColumns: ["source_id"]
          },
        ]
      }
      archon_project_sources: {
        Row: {
          created_by: string | null
          id: string
          linked_at: string | null
          notes: string | null
          project_id: string | null
          source_id: string
        }
        Insert: {
          created_by?: string | null
          id?: string
          linked_at?: string | null
          notes?: string | null
          project_id?: string | null
          source_id: string
        }
        Update: {
          created_by?: string | null
          id?: string
          linked_at?: string | null
          notes?: string | null
          project_id?: string | null
          source_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "archon_project_sources_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "archon_projects"
            referencedColumns: ["id"]
          },
        ]
      }
      archon_projects: {
        Row: {
          created_at: string | null
          data: Json | null
          description: string | null
          docs: Json | null
          features: Json | null
          github_repo: string | null
          id: string
          pinned: boolean | null
          title: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          data?: Json | null
          description?: string | null
          docs?: Json | null
          features?: Json | null
          github_repo?: string | null
          id?: string
          pinned?: boolean | null
          title: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          data?: Json | null
          description?: string | null
          docs?: Json | null
          features?: Json | null
          github_repo?: string | null
          id?: string
          pinned?: boolean | null
          title?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      archon_prompts: {
        Row: {
          created_at: string | null
          description: string | null
          id: string
          prompt: string
          prompt_name: string
          updated_at: string | null
        }
        Insert: {
          created_at?: string | null
          description?: string | null
          id?: string
          prompt: string
          prompt_name: string
          updated_at?: string | null
        }
        Update: {
          created_at?: string | null
          description?: string | null
          id?: string
          prompt?: string
          prompt_name?: string
          updated_at?: string | null
        }
        Relationships: []
      }
      archon_settings: {
        Row: {
          category: string | null
          created_at: string | null
          description: string | null
          encrypted_value: string | null
          id: string
          is_encrypted: boolean | null
          key: string
          updated_at: string | null
          value: string | null
        }
        Insert: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          encrypted_value?: string | null
          id?: string
          is_encrypted?: boolean | null
          key: string
          updated_at?: string | null
          value?: string | null
        }
        Update: {
          category?: string | null
          created_at?: string | null
          description?: string | null
          encrypted_value?: string | null
          id?: string
          is_encrypted?: boolean | null
          key?: string
          updated_at?: string | null
          value?: string | null
        }
        Relationships: []
      }
      archon_sources: {
        Row: {
          created_at: string
          metadata: Json | null
          source_display_name: string | null
          source_id: string
          source_url: string | null
          summary: string | null
          title: string | null
          total_word_count: number | null
          updated_at: string
        }
        Insert: {
          created_at?: string
          metadata?: Json | null
          source_display_name?: string | null
          source_id: string
          source_url?: string | null
          summary?: string | null
          title?: string | null
          total_word_count?: number | null
          updated_at?: string
        }
        Update: {
          created_at?: string
          metadata?: Json | null
          source_display_name?: string | null
          source_id?: string
          source_url?: string | null
          summary?: string | null
          title?: string | null
          total_word_count?: number | null
          updated_at?: string
        }
        Relationships: []
      }
      archon_tasks: {
        Row: {
          archived: boolean | null
          archived_at: string | null
          archived_by: string | null
          assignee: string | null
          code_examples: Json | null
          created_at: string | null
          description: string | null
          feature: string | null
          id: string
          parent_task_id: string | null
          priority: Database["public"]["Enums"]["task_priority"]
          project_id: string | null
          sources: Json | null
          status: Database["public"]["Enums"]["task_status"] | null
          task_order: number | null
          title: string
          updated_at: string | null
        }
        Insert: {
          archived?: boolean | null
          archived_at?: string | null
          archived_by?: string | null
          assignee?: string | null
          code_examples?: Json | null
          created_at?: string | null
          description?: string | null
          feature?: string | null
          id?: string
          parent_task_id?: string | null
          priority?: Database["public"]["Enums"]["task_priority"]
          project_id?: string | null
          sources?: Json | null
          status?: Database["public"]["Enums"]["task_status"] | null
          task_order?: number | null
          title: string
          updated_at?: string | null
        }
        Update: {
          archived?: boolean | null
          archived_at?: string | null
          archived_by?: string | null
          assignee?: string | null
          code_examples?: Json | null
          created_at?: string | null
          description?: string | null
          feature?: string | null
          id?: string
          parent_task_id?: string | null
          priority?: Database["public"]["Enums"]["task_priority"]
          project_id?: string | null
          sources?: Json | null
          status?: Database["public"]["Enums"]["task_status"] | null
          task_order?: number | null
          title?: string
          updated_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "archon_tasks_parent_task_id_fkey"
            columns: ["parent_task_id"]
            isOneToOne: false
            referencedRelation: "archon_tasks"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "archon_tasks_project_id_fkey"
            columns: ["project_id"]
            isOneToOne: false
            referencedRelation: "archon_projects"
            referencedColumns: ["id"]
          },
        ]
      }
      consents: {
        Row: {
          created_at: string | null
          id: string
          revoked_at: string | null
          scopes: Json
          user_id: string
          version: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          revoked_at?: string | null
          scopes?: Json
          user_id: string
          version: string
        }
        Update: {
          created_at?: string | null
          id?: string
          revoked_at?: string | null
          scopes?: Json
          user_id?: string
          version?: string
        }
        Relationships: []
      }
      cycle_data: {
        Row: {
          age: number
          created_at: string | null
          cycle_length: number
          id: string
          last_period: string
          period_duration: number
          user_id: string
        }
        Insert: {
          age: number
          created_at?: string | null
          cycle_length: number
          id?: string
          last_period: string
          period_duration: number
          user_id: string
        }
        Update: {
          age?: number
          created_at?: string | null
          cycle_length?: number
          id?: string
          last_period?: string
          period_duration?: number
          user_id?: string
        }
        Relationships: []
      }
      daily_plan: {
        Row: {
          activities: Json | null
          created_at: string | null
          date: string
          energy_level: number | null
          exercise_minutes: number | null
          id: string
          mood: string | null
          notes: string | null
          nutrition: Json | null
          sleep_hours: number | null
          symptoms: Json | null
          updated_at: string | null
          user_id: string
          water_intake_ml: number | null
        }
        Insert: {
          activities?: Json | null
          created_at?: string | null
          date: string
          energy_level?: number | null
          exercise_minutes?: number | null
          id?: string
          mood?: string | null
          notes?: string | null
          nutrition?: Json | null
          sleep_hours?: number | null
          symptoms?: Json | null
          updated_at?: string | null
          user_id: string
          water_intake_ml?: number | null
        }
        Update: {
          activities?: Json | null
          created_at?: string | null
          date?: string
          energy_level?: number | null
          exercise_minutes?: number | null
          id?: string
          mood?: string | null
          notes?: string | null
          nutrition?: Json | null
          sleep_hours?: number | null
          symptoms?: Json | null
          updated_at?: string | null
          user_id?: string
          water_intake_ml?: number | null
        }
        Relationships: []
      }
      email_preferences: {
        Row: {
          created_at: string | null
          id: string
          newsletter: boolean | null
          user_id: string
        }
        Insert: {
          created_at?: string | null
          id?: string
          newsletter?: boolean | null
          user_id: string
        }
        Update: {
          created_at?: string | null
          id?: string
          newsletter?: boolean | null
          user_id?: string
        }
        Relationships: []
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      archive_task: {
        Args: { archived_by_param?: string; task_id_param: string }
        Returns: boolean
      }
      detect_embedding_dimension: {
        Args: { embedding_vector: string }
        Returns: number
      }
      get_embedding_column_name: {
        Args: { dimension: number }
        Returns: string
      }
      hybrid_search_archon_code_examples: {
        Args: {
          filter?: Json
          match_count?: number
          query_embedding: string
          query_text: string
          source_filter?: string
        }
        Returns: {
          chunk_number: number
          content: string
          id: number
          match_type: string
          metadata: Json
          similarity: number
          source_id: string
          summary: string
          url: string
        }[]
      }
      hybrid_search_archon_code_examples_multi: {
        Args: {
          embedding_dimension: number
          filter?: Json
          match_count?: number
          query_embedding: string
          query_text: string
          source_filter?: string
        }
        Returns: {
          chunk_number: number
          content: string
          id: number
          match_type: string
          metadata: Json
          similarity: number
          source_id: string
          summary: string
          url: string
        }[]
      }
      hybrid_search_archon_crawled_pages: {
        Args: {
          filter?: Json
          match_count?: number
          query_embedding: string
          query_text: string
          source_filter?: string
        }
        Returns: {
          chunk_number: number
          content: string
          id: number
          match_type: string
          metadata: Json
          similarity: number
          source_id: string
          url: string
        }[]
      }
      hybrid_search_archon_crawled_pages_multi: {
        Args: {
          embedding_dimension: number
          filter?: Json
          match_count?: number
          query_embedding: string
          query_text: string
          source_filter?: string
        }
        Returns: {
          chunk_number: number
          content: string
          id: number
          match_type: string
          metadata: Json
          similarity: number
          source_id: string
          url: string
        }[]
      }
      match_archon_code_examples: {
        Args: {
          filter?: Json
          match_count?: number
          query_embedding: string
          source_filter?: string
        }
        Returns: {
          chunk_number: number
          content: string
          id: number
          metadata: Json
          similarity: number
          source_id: string
          summary: string
          url: string
        }[]
      }
      match_archon_code_examples_multi: {
        Args: {
          embedding_dimension: number
          filter?: Json
          match_count?: number
          query_embedding: string
          source_filter?: string
        }
        Returns: {
          chunk_number: number
          content: string
          id: number
          metadata: Json
          similarity: number
          source_id: string
          summary: string
          url: string
        }[]
      }
      match_archon_crawled_pages: {
        Args: {
          filter?: Json
          match_count?: number
          query_embedding: string
          source_filter?: string
        }
        Returns: {
          chunk_number: number
          content: string
          id: number
          metadata: Json
          similarity: number
          source_id: string
          url: string
        }[]
      }
      match_archon_crawled_pages_multi: {
        Args: {
          embedding_dimension: number
          filter?: Json
          match_count?: number
          query_embedding: string
          source_filter?: string
        }
        Returns: {
          chunk_number: number
          content: string
          id: number
          metadata: Json
          similarity: number
          source_id: string
          url: string
        }[]
      }
      show_limit: { Args: never; Returns: number }
      show_trgm: { Args: { "": string }; Returns: string[] }
    }
    Enums: {
      task_priority: "low" | "medium" | "high" | "critical"
      task_status: "todo" | "doing" | "review" | "done"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      task_priority: ["low", "medium", "high", "critical"],
      task_status: ["todo", "doing", "review", "done"],
    },
  },
} as const
