#
# Cookbook Name:: mailserver
# Recipe:: default
#
# Copyright 2012, Pascal Ehlert
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Generate the required databases on all db servers
::Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

include_recipe "database"

# generate all passwords
node.set_unless['mailserver']['db_mailadmin_password'] = secure_password
node.set_unless['mailserver']['db_mailauth_password'] = secure_password

db_connection = { :host => 'localhost', :username => 'postgres', :password => node[:postgresql][:password][:postgres] }

postgresql_database_user 'mailadmin' do
  connection db_connection
  password node['mailserver']['db_mailadmin_password'] 
  action :create
end

postgresql_database_user 'mailauth' do
  connection db_connection
  password node['mailserver']['db_mailauth_password'] 
  action :create
end

postgresql_database 'mailconfig' do
  connection db_connection
  action :create
end

mailconfig_sql = <<END
--
-- Name: admin; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE admin (
    username character varying(255) NOT NULL,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.admin OWNER TO mailadmin;

--
-- Name: TABLE admin; Type: COMMENT; Schema: public; Owner: mailadmin
--

COMMENT ON TABLE admin IS 'Postfix Admin - Virtual Admins';


--
-- Name: alias; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE alias (
    address character varying(255) NOT NULL,
    goto text NOT NULL,
    domain character varying(255) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.alias OWNER TO mailadmin;

--
-- Name: TABLE alias; Type: COMMENT; Schema: public; Owner: mailadmin
--

COMMENT ON TABLE alias IS 'Postfix Admin - Virtual Aliases';


--
-- Name: alias_domain; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE alias_domain (
    alias_domain character varying(255) NOT NULL,
    target_domain character varying(255) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.alias_domain OWNER TO mailadmin;

--
-- Name: TABLE alias_domain; Type: COMMENT; Schema: public; Owner: mailadmin
--

COMMENT ON TABLE alias_domain IS 'Postfix Admin - Domain Aliases';


--
-- Name: config; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE config (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    value character varying(20) NOT NULL
);


ALTER TABLE public.config OWNER TO mailadmin;

--
-- Name: config_id_seq; Type: SEQUENCE; Schema: public; Owner: mailadmin
--

CREATE SEQUENCE config_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.config_id_seq OWNER TO mailadmin;

--
-- Name: config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mailadmin
--

ALTER SEQUENCE config_id_seq OWNED BY config.id;


--
-- Name: domain; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE domain (
    domain character varying(255) NOT NULL,
    description character varying(255) DEFAULT ''::character varying NOT NULL,
    aliases integer DEFAULT 0 NOT NULL,
    mailboxes integer DEFAULT 0 NOT NULL,
    maxquota integer DEFAULT 0 NOT NULL,
    quota integer DEFAULT 0 NOT NULL,
    transport character varying(255) DEFAULT NULL::character varying,
    backupmx boolean DEFAULT false NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.domain OWNER TO mailadmin;

--
-- Name: TABLE domain; Type: COMMENT; Schema: public; Owner: mailadmin
--

COMMENT ON TABLE domain IS 'Postfix Admin - Virtual Domains';


--
-- Name: domain_admins; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE domain_admins (
    username character varying(255) NOT NULL,
    domain character varying(255) NOT NULL,
    created timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.domain_admins OWNER TO mailadmin;

--
-- Name: TABLE domain_admins; Type: COMMENT; Schema: public; Owner: mailadmin
--

COMMENT ON TABLE domain_admins IS 'Postfix Admin - Domain Admins';


--
-- Name: fetchmail; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE fetchmail (
    id integer NOT NULL,
    mailbox character varying(255) DEFAULT ''::character varying NOT NULL,
    src_server character varying(255) DEFAULT ''::character varying NOT NULL,
    src_auth character varying(15) NOT NULL,
    src_user character varying(255) DEFAULT ''::character varying NOT NULL,
    src_password character varying(255) DEFAULT ''::character varying NOT NULL,
    src_folder character varying(255) DEFAULT ''::character varying NOT NULL,
    poll_time integer DEFAULT 10 NOT NULL,
    fetchall boolean DEFAULT false NOT NULL,
    keep boolean DEFAULT false NOT NULL,
    protocol character varying(15) NOT NULL,
    extra_options text,
    returned_text text,
    mda character varying(255) DEFAULT ''::character varying NOT NULL,
    date timestamp with time zone DEFAULT now(),
    usessl boolean DEFAULT false NOT NULL,
    CONSTRAINT fetchmail_protocol_check CHECK (((protocol)::text = ANY ((ARRAY['POP3'::character varying, 'IMAP'::character varying, 'POP2'::character varying, 'ETRN'::character varying, 'AUTO'::character varying])::text[]))),
    CONSTRAINT fetchmail_src_auth_check CHECK (((src_auth)::text = ANY ((ARRAY['password'::character varying, 'kerberos_v5'::character varying, 'kerberos'::character varying, 'kerberos_v4'::character varying, 'gssapi'::character varying, 'cram-md5'::character varying, 'otp'::character varying, 'ntlm'::character varying, 'msn'::character varying, 'ssh'::character varying, 'any'::character varying])::text[])))
);


ALTER TABLE public.fetchmail OWNER TO mailadmin;

--
-- Name: fetchmail_id_seq; Type: SEQUENCE; Schema: public; Owner: mailadmin
--

CREATE SEQUENCE fetchmail_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.fetchmail_id_seq OWNER TO mailadmin;

--
-- Name: fetchmail_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mailadmin
--

ALTER SEQUENCE fetchmail_id_seq OWNED BY fetchmail.id;


--
-- Name: log; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE log (
    "timestamp" timestamp with time zone DEFAULT now(),
    username character varying(255) DEFAULT ''::character varying NOT NULL,
    domain character varying(255) DEFAULT ''::character varying NOT NULL,
    action character varying(255) DEFAULT ''::character varying NOT NULL,
    data text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.log OWNER TO mailadmin;

--
-- Name: TABLE log; Type: COMMENT; Schema: public; Owner: mailadmin
--

COMMENT ON TABLE log IS 'Postfix Admin - Log';


--
-- Name: mailbox; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE mailbox (
    username character varying(255) NOT NULL,
    password character varying(255) DEFAULT ''::character varying NOT NULL,
    name character varying(255) DEFAULT ''::character varying NOT NULL,
    maildir character varying(255) DEFAULT ''::character varying NOT NULL,
    quota integer DEFAULT 0 NOT NULL,
    created timestamp with time zone DEFAULT now(),
    modified timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    domain character varying(255),
    local_part character varying(255) NOT NULL
);


ALTER TABLE public.mailbox OWNER TO mailadmin;

--
-- Name: TABLE mailbox; Type: COMMENT; Schema: public; Owner: mailadmin
--

COMMENT ON TABLE mailbox IS 'Postfix Admin - Virtual Mailboxes';


--
-- Name: quota; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE quota (
    username character varying(255) NOT NULL,
    path character varying(100) NOT NULL,
    current bigint
);


ALTER TABLE public.quota OWNER TO mailadmin;

--
-- Name: quota2; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE quota2 (
    username character varying(100) NOT NULL,
    bytes bigint DEFAULT 0 NOT NULL,
    messages integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.quota2 OWNER TO mailadmin;

--
-- Name: vacation; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE vacation (
    email character varying(255) NOT NULL,
    subject character varying(255) NOT NULL,
    body text DEFAULT ''::text NOT NULL,
    created timestamp with time zone DEFAULT now(),
    active boolean DEFAULT true NOT NULL,
    domain character varying(255)
);


ALTER TABLE public.vacation OWNER TO mailadmin;

--
-- Name: vacation_notification; Type: TABLE; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE TABLE vacation_notification (
    on_vacation character varying(255) NOT NULL,
    notified character varying(255) NOT NULL,
    notified_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.vacation_notification OWNER TO mailadmin;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mailadmin
--

ALTER TABLE ONLY config ALTER COLUMN id SET DEFAULT nextval('config_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: mailadmin
--

ALTER TABLE ONLY fetchmail ALTER COLUMN id SET DEFAULT nextval('fetchmail_id_seq'::regclass);


--
-- Name: admin_key; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY admin
    ADD CONSTRAINT admin_key PRIMARY KEY (username);


--
-- Name: alias_domain_pkey; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY alias_domain
    ADD CONSTRAINT alias_domain_pkey PRIMARY KEY (alias_domain);


--
-- Name: alias_key; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT alias_key PRIMARY KEY (address);


--
-- Name: config_name_key; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY config
    ADD CONSTRAINT config_name_key UNIQUE (name);


--
-- Name: config_pkey; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY config
    ADD CONSTRAINT config_pkey PRIMARY KEY (id);


--
-- Name: domain_key; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY domain
    ADD CONSTRAINT domain_key PRIMARY KEY (domain);


--
-- Name: fetchmail_pkey; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY fetchmail
    ADD CONSTRAINT fetchmail_pkey PRIMARY KEY (id);


--
-- Name: mailbox_key; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY mailbox
    ADD CONSTRAINT mailbox_key PRIMARY KEY (username);


--
-- Name: quota2_pkey; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY quota2
    ADD CONSTRAINT quota2_pkey PRIMARY KEY (username);


--
-- Name: quota_pkey; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY quota
    ADD CONSTRAINT quota_pkey PRIMARY KEY (username, path);


--
-- Name: vacation_notification_pkey; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY vacation_notification
    ADD CONSTRAINT vacation_notification_pkey PRIMARY KEY (on_vacation, notified);


--
-- Name: vacation_pkey; Type: CONSTRAINT; Schema: public; Owner: mailadmin; Tablespace: 
--

ALTER TABLE ONLY vacation
    ADD CONSTRAINT vacation_pkey PRIMARY KEY (email);


--
-- Name: alias_address_active; Type: INDEX; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE INDEX alias_address_active ON alias USING btree (address, active);


--
-- Name: alias_domain_active; Type: INDEX; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE INDEX alias_domain_active ON alias_domain USING btree (alias_domain, active);


--
-- Name: alias_domain_idx; Type: INDEX; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE INDEX alias_domain_idx ON alias USING btree (domain);


--
-- Name: domain_domain_active; Type: INDEX; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE INDEX domain_domain_active ON domain USING btree (domain, active);


--
-- Name: mailbox_domain_idx; Type: INDEX; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE INDEX mailbox_domain_idx ON mailbox USING btree (domain);


--
-- Name: mailbox_username_active; Type: INDEX; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE INDEX mailbox_username_active ON mailbox USING btree (username, active);


--
-- Name: vacation_email_active; Type: INDEX; Schema: public; Owner: mailadmin; Tablespace: 
--

CREATE INDEX vacation_email_active ON vacation USING btree (email, active);


--
-- Name: alias_domain_alias_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mailadmin
--

ALTER TABLE ONLY alias_domain
    ADD CONSTRAINT alias_domain_alias_domain_fkey FOREIGN KEY (alias_domain) REFERENCES domain(domain) ON DELETE CASCADE;


--
-- Name: alias_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mailadmin
--

ALTER TABLE ONLY alias
    ADD CONSTRAINT alias_domain_fkey FOREIGN KEY (domain) REFERENCES domain(domain);


--
-- Name: alias_domain_target_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mailadmin
--

ALTER TABLE ONLY alias_domain
    ADD CONSTRAINT alias_domain_target_domain_fkey FOREIGN KEY (target_domain) REFERENCES domain(domain) ON DELETE CASCADE;


--
-- Name: domain_admins_domain_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mailadmin
--

ALTER TABLE ONLY domain_admins
    ADD CONSTRAINT domain_admins_domain_fkey FOREIGN KEY (domain) REFERENCES domain(domain);


--
-- Name: mailbox_domain_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: mailadmin
--

ALTER TABLE ONLY mailbox
    ADD CONSTRAINT mailbox_domain_fkey1 FOREIGN KEY (domain) REFERENCES domain(domain);


--
-- Name: vacation_domain_fkey1; Type: FK CONSTRAINT; Schema: public; Owner: mailadmin
--

ALTER TABLE ONLY vacation
    ADD CONSTRAINT vacation_domain_fkey1 FOREIGN KEY (domain) REFERENCES domain(domain);


--
-- Name: vacation_notification_on_vacation_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mailadmin
--

ALTER TABLE ONLY vacation_notification
    ADD CONSTRAINT vacation_notification_on_vacation_fkey FOREIGN KEY (on_vacation) REFERENCES vacation(email) ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: admin; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE admin FROM PUBLIC;
REVOKE ALL ON TABLE admin FROM mailadmin;
GRANT ALL ON TABLE admin TO mailadmin;
GRANT SELECT ON TABLE admin TO mailauth;


--
-- Name: alias; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE alias FROM PUBLIC;
REVOKE ALL ON TABLE alias FROM mailadmin;
GRANT ALL ON TABLE alias TO mailadmin;
GRANT SELECT ON TABLE alias TO mailauth;


--
-- Name: config; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE config FROM PUBLIC;
REVOKE ALL ON TABLE config FROM mailadmin;
GRANT ALL ON TABLE config TO mailadmin;
GRANT SELECT ON TABLE config TO mailauth;


--
-- Name: config_id_seq; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON SEQUENCE config_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE config_id_seq FROM mailadmin;
GRANT ALL ON SEQUENCE config_id_seq TO mailadmin;
GRANT SELECT ON SEQUENCE config_id_seq TO mailauth;


--
-- Name: domain; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE domain FROM PUBLIC;
REVOKE ALL ON TABLE domain FROM mailadmin;
GRANT ALL ON TABLE domain TO mailadmin;
GRANT SELECT ON TABLE domain TO mailauth;


--
-- Name: domain_admins; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE domain_admins FROM PUBLIC;
REVOKE ALL ON TABLE domain_admins FROM mailadmin;
GRANT ALL ON TABLE domain_admins TO mailadmin;
GRANT SELECT ON TABLE domain_admins TO mailauth;


--
-- Name: fetchmail; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE fetchmail FROM PUBLIC;
REVOKE ALL ON TABLE fetchmail FROM mailadmin;
GRANT ALL ON TABLE fetchmail TO mailadmin;
GRANT SELECT ON TABLE fetchmail TO mailauth;


--
-- Name: fetchmail_id_seq; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON SEQUENCE fetchmail_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE fetchmail_id_seq FROM mailadmin;
GRANT ALL ON SEQUENCE fetchmail_id_seq TO mailadmin;
GRANT SELECT ON SEQUENCE fetchmail_id_seq TO mailauth;


--
-- Name: log; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE log FROM PUBLIC;
REVOKE ALL ON TABLE log FROM mailadmin;
GRANT ALL ON TABLE log TO mailadmin;
GRANT SELECT ON TABLE log TO mailauth;


--
-- Name: mailbox; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE mailbox FROM PUBLIC;
REVOKE ALL ON TABLE mailbox FROM mailadmin;
GRANT ALL ON TABLE mailbox TO mailadmin;
GRANT SELECT ON TABLE mailbox TO mailauth;


--
-- Name: vacation; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE vacation FROM PUBLIC;
REVOKE ALL ON TABLE vacation FROM mailadmin;
GRANT ALL ON TABLE vacation TO mailadmin;
GRANT SELECT ON TABLE vacation TO mailauth;


--
-- Name: vacation_notification; Type: ACL; Schema: public; Owner: mailadmin
--

REVOKE ALL ON TABLE vacation_notification FROM PUBLIC;
REVOKE ALL ON TABLE vacation_notification FROM mailadmin;
GRANT ALL ON TABLE vacation_notification TO mailadmin;
GRANT SELECT ON TABLE vacation_notification TO mailauth;


--
-- PostgreSQL database dump complete
--

END

# This will run the query to create the basic structure every time the database state changes (should happen only once on creation)
postgresql_database 'mailconfig-create-tables' do
  database_name "mailconfig"
  connection db_connection
  sql mailconfig_sql
  action :nothing
  subscribes :query, resources("postgresql_database[mailconfig]"), :immediately
end

include_recipe "mailserver::dovecot"
include_recipe "mailserver::amavis"
include_recipe "mailserver::clamav"
include_recipe "mailserver::spamassassin"
include_recipe "mailserver::postfix"
include_recipe "mailserver::postfixadmin"
