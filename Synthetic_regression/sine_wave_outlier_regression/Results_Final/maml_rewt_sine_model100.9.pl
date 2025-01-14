��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq clearn2learn.algorithms.maml
MAML
qXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\learn2learn\algorithms\maml.pyqX�  class MAML(BaseLearner):
    """

    [[Source]](https://github.com/learnables/learn2learn/blob/master/learn2learn/algorithms/maml.py)

    **Description**

    High-level implementation of *Model-Agnostic Meta-Learning*.

    This class wraps an arbitrary nn.Module and augments it with `clone()` and `adapt()`
    methods.

    For the first-order version of MAML (i.e. FOMAML), set the `first_order` flag to `True`
    upon initialization.

    **Arguments**

    * **model** (Module) - Module to be wrapped.
    * **lr** (float) - Fast adaptation learning rate.
    * **first_order** (bool, *optional*, default=False) - Whether to use the first-order
        approximation of MAML. (FOMAML)
    * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to `allow_nograd`.
    * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
        parameters that have `requires_grad = False`.

    **References**

    1. Finn et al. 2017. "Model-Agnostic Meta-Learning for Fast Adaptation of Deep Networks."

    **Example**

    ~~~python
    linear = l2l.algorithms.MAML(nn.Linear(20, 10), lr=0.01)
    clone = linear.clone()
    error = loss(clone(X), y)
    clone.adapt(error)
    error = loss(clone(X), y)
    error.backward()
    ~~~
    """

    def __init__(self,
                 model,
                 lr,
                 first_order=False,
                 allow_unused=None,
                 allow_nograd=False):
        super(MAML, self).__init__()
        self.module = model
        self.lr = lr
        self.first_order = first_order
        self.allow_nograd = allow_nograd
        if allow_unused is None:
            allow_unused = allow_nograd
        self.allow_unused = allow_unused

    def forward(self, *args, **kwargs):
        return self.module(*args, **kwargs)

    def adapt(self,
              loss,
              first_order=None,
              allow_unused=None,
              allow_nograd=None):
        """
        **Description**

        Takes a gradient step on the loss and updates the cloned parameters in place.

        **Arguments**

        * **loss** (Tensor) - Loss to minimize upon update.
        * **first_order** (bool, *optional*, default=None) - Whether to use first- or
            second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
            of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=None) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        second_order = not first_order

        if allow_nograd:
            # Compute relevant gradients
            diff_params = [p for p in self.module.parameters() if p.requires_grad]
            grad_params = grad(loss,
                               diff_params,
                               retain_graph=second_order,
                               create_graph=second_order,
                               allow_unused=allow_unused)
            gradients = []
            grad_counter = 0

            # Handles gradients for non-differentiable parameters
            for param in self.module.parameters():
                if param.requires_grad:
                    gradient = grad_params[grad_counter]
                    grad_counter += 1
                else:
                    gradient = None
                gradients.append(gradient)
        else:
            try:
                gradients = grad(loss,
                                 self.module.parameters(),
                                 retain_graph=second_order,
                                 create_graph=second_order,
                                 allow_unused=allow_unused)
            except RuntimeError:
                traceback.print_exc()
                print('learn2learn: Maybe try with allow_nograd=True and/or allow_unused=True ?')

        # Update the module
        self.module = maml_update(self.module, self.lr, gradients)

    def clone(self, first_order=None, allow_unused=None, allow_nograd=None):
        """
        **Description**

        Returns a `MAML`-wrapped copy of the module whose parameters and buffers
        are `torch.clone`d from the original module.

        This implies that back-propagating losses on the cloned module will
        populate the buffers of the original module.
        For more information, refer to learn2learn.clone_module().

        **Arguments**

        * **first_order** (bool, *optional*, default=None) - Whether the clone uses first-
            or second-order updates. Defaults to self.first_order.
        * **allow_unused** (bool, *optional*, default=None) - Whether to allow differentiation
        of unused parameters. Defaults to self.allow_unused.
        * **allow_nograd** (bool, *optional*, default=False) - Whether to allow adaptation with
            parameters that have `requires_grad = False`. Defaults to self.allow_nograd.

        """
        if first_order is None:
            first_order = self.first_order
        if allow_unused is None:
            allow_unused = self.allow_unused
        if allow_nograd is None:
            allow_nograd = self.allow_nograd
        return MAML(clone_module(self.module),
                    lr=self.lr,
                    first_order=first_order,
                    allow_unused=allow_unused,
                    allow_nograd=allow_nograd)
qtqQ)�q}q(X   trainingq�X   _parametersqccollections
OrderedDict
q	)Rq
X   _buffersqh	)RqX   _backward_hooksqh	)RqX   _forward_hooksqh	)RqX   _forward_pre_hooksqh	)RqX   _state_dict_hooksqh	)RqX   _load_state_dict_pre_hooksqh	)RqX   _modulesqh	)Rqh (h csine_wave_outlier_regression.maml_synthetic_reweight
SyntheticMAMLModel
qX�   C:\Users\krish\OneDrive - The University of Texas at Dallas\Documents\metaL-dss\sine_wave_outlier_regression\maml_synthetic_reweight.pyqXU  class SyntheticMAMLModel(nn.Module):
    def __init__(self):
        super(SyntheticMAMLModel, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(1, 40),
            nn.ReLU(),
            nn.Linear(40, 40),
            nn.ReLU(),
            nn.Linear(40, 1))

    def forward(self, x):
        return self.model(x)
qtqQ)�q}q(h�hh	)Rqhh	)Rq hh	)Rq!hh	)Rq"hh	)Rq#hh	)Rq$hh	)Rq%hh	)Rq&X   modelq'(h ctorch.nn.modules.container
Sequential
q(XU   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\container.pyq)XE
  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    @_copy_to_script_wrapper
    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    @_copy_to_script_wrapper
    def __len__(self):
        return len(self._modules)

    @_copy_to_script_wrapper
    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    @_copy_to_script_wrapper
    def __iter__(self):
        return iter(self._modules.values())

    def forward(self, input):
        for module in self:
            input = module(input)
        return input
q*tq+Q)�q,}q-(h�hh	)Rq.hh	)Rq/hh	)Rq0hh	)Rq1hh	)Rq2hh	)Rq3hh	)Rq4hh	)Rq5(X   0q6(h ctorch.nn.modules.linear
Linear
q7XR   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\linear.pyq8X�	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to ``False``, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, H_{in})` where :math:`*` means any number of
          additional dimensions and :math:`H_{in} = \text{in\_features}`
        - Output: :math:`(N, *, H_{out})` where all but the last dimension
          are the same shape as the input and :math:`H_{out} = \text{out\_features}`.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['in_features', 'out_features']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
q9tq:Q)�q;}q<(h�hh	)Rq=(X   weightq>ctorch._utils
_rebuild_parameter
q?ctorch._utils
_rebuild_tensor_v2
q@((X   storageqActorch
FloatStorage
qBX   2128939551216qCX   cuda:0qDK(NtqEQK K(K�qFKK�qG�h	)RqHtqIRqJ�h	)RqK�qLRqMX   biasqNh?h@((hAhBX   2128939547280qOX   cuda:0qPK(NtqQQK K(�qRK�qS�h	)RqTtqURqV�h	)RqW�qXRqYuhh	)RqZhh	)Rq[hh	)Rq\hh	)Rq]hh	)Rq^hh	)Rq_hh	)Rq`X   in_featuresqaKX   out_featuresqbK(ubX   1qc(h ctorch.nn.modules.activation
ReLU
qdXV   C:\ProgramData\Anaconda3\envs\pytorch\lib\site-packages\torch\nn\modules\activation.pyqeXB  class ReLU(Module):
    r"""Applies the rectified linear unit function element-wise:

    :math:`\text{ReLU}(x) = (x)^+ = \max(0, x)`

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    .. image:: scripts/activation_images/ReLU.png

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)


      An implementation of CReLU - https://arxiv.org/abs/1603.05201

        >>> m = nn.ReLU()
        >>> input = torch.randn(2).unsqueeze(0)
        >>> output = torch.cat((m(input),m(-input)))
    """
    __constants__ = ['inplace']

    def __init__(self, inplace=False):
        super(ReLU, self).__init__()
        self.inplace = inplace

    def forward(self, input):
        return F.relu(input, inplace=self.inplace)

    def extra_repr(self):
        inplace_str = 'inplace=True' if self.inplace else ''
        return inplace_str
qftqgQ)�qh}qi(h�hh	)Rqjhh	)Rqkhh	)Rqlhh	)Rqmhh	)Rqnhh	)Rqohh	)Rqphh	)RqqX   inplaceqr�ubX   2qsh7)�qt}qu(h�hh	)Rqv(h>h?h@((hAhBX   2128939552368qwX   cuda:0qxM@NtqyQK K(K(�qzK(K�q{�h	)Rq|tq}Rq~�h	)Rq�q�Rq�hNh?h@((hAhBX   2128939547088q�X   cuda:0q�K(Ntq�QK K(�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbK(ubX   3q�hd)�q�}q�(h�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hr�ubX   4q�h7)�q�}q�(h�hh	)Rq�(h>h?h@((hAhBX   2128939547664q�X   cuda:0q�K(Ntq�QK KK(�q�K(K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�hNh?h@((hAhBX   2128939552176q�X   cuda:0q�KNtq�QK K�q�K�q��h	)Rq�tq�Rq��h	)Rq��q�Rq�uhh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�hh	)Rq�haK(hbKubuubsubsX   lrq�G?�z�G�{X   first_orderq��X   allow_nogradqX   allow_unusedqÉub.�]q (X   2128939547088qX   2128939547280qX   2128939547664qX   2128939551216qX   2128939552176qX   2128939552368qe.(       [,?fd?}
�XO�eQ.��Ľ� 
<!h��籽��n���z��B�>����>�B�u(?�Q��^E�>��7��8���<M�L��=R���q=7�j�n�s��"�Ҿ�=��¾�n@<����T���KX%�3(U��uɾ��:<6nϾ�����>C��h��(       �`��y�X���<V?V��������ſ�u������!����WοT0�>}��>�dп����ING�i��	?��W�陘�-%ſV5�>�����ݿ����*$?�u��z�7���	�֣D���>��/@ٿ�п>�e?����%��onM?ѕ��(       �!ɾ���>V�K�^j���.�j��<�.�f �J7c�(W>`p?IV�=�}��Q&�h���#Y?�_y=hF?͈�=��.��ﹼy�G���Ͻ�#�=%���q���?g�h�!_�>p�ս��
���|>^���ר»��1>�� ?�6d?��>sn!�(       MS���>� �q3�pj�~�V�U��d�Y�d�g�ҭ>�$?.?Y�?��r潝X
?�0�>��C���z<�Я�A��> ��>��K�_�0�u ?U' ���;|�����?�����I�+?B?��̼�[�=�? �W>�!��½��ںe��	׹�       O&]�@      �=j���#��2� ���þ���< c�;�<U+
�}Y�"�ݽT�e<4Gb��G
���ȾIf6������$;��=� =�2C�"�N��T����<S��Iµ��7��1.�E�>��	�Wf!>˔%�={1=�N����>G�쿢�ɽ�
f�l��>wq��5�;A���)��>�
��6i4�˔=H�̿C��E����,��Ş�>W�5����?���=�����q7�0h̾tuy>G�>�J�>��ҿ{�E�i"���*�#[�9־�>M�p�t�̽śA�-��>�V�H������F����ѽ.*��zed���������X���s�=-�K����
狾�}����?=F�Z���$����<�>�+���s��@n?˔�%��� �*��=�;���>�r��(>��7ݾ���<ax�e=�<�?�k�� ? =��F�(ө=a-(>�c�<0䷾�w�>:ݾV���/۽ov"����>n޼#6�=�X�=���=#�����B�Od��
�0��WH�sE�Ox#�#�=�gp�����o��b�=Qcۻ��b<[�h=�ٽb�=��3��a�"�[�=DƑ=�\�X��.��=A��M\={5#�	�0=m`=�z�=�P�=>6�=��
>N��mڛ�op�=�_��>֞=ߧj����=k��=�G+�� "��7�v>�5y�`���M�;=���=����?�<ӍS<�]D�cC�=��a�'uѽ$,T=�T1=z�"<R��=��2��wC��T��Z��*.�=(1D�@�վs,��*<_��=�TX:��=ܔ%<]3�/�]�;g(�Zm�ͅ$=K�<��	�$�������-��=t���z��>t
ӾO�.>�;�?9���"=�2���k��\���[a�� ��<p�w=�ν+)Y�J��� �=���?�W;���޽Z�Z�:��=CI�?"^��ʥ������b�>���=�5�=Nʙ�]�ǿ�`�=���=�<���YG>'/��jH��/=�D��F�A{E�b�����q�.ڽB�Ƽl�=t�>q=>BPM=��W�^��<��h�VdB;iY:=/I���C��0q��Ә���6=�e�<�F�>�̹��x�2c>?3��}�ͽO���:���PA=�A��P=jY��������P=L�E�UKݽgd�DkL="�=|õ�%�=�wa�vt�=e$�=�qw�����='��<ؚ�<輣�(�����6ɼ(2��֩)��r=��ؽk�I����!�}���	뛼�½��,�;�������8=���\�}="��<��=���<z>�P-�<0��= U���/Ľ��μ������� <��`�����H�e뮽�@1�� R��F߽�����什V��̞��Q���Ѽv��d��I��@h
=�c+�ӫH��>�N4p����=Kl���������̩i=���=62p�Lr*�e�l�ھ�=Z�D<|vӿ���<q]�=$�;g[���	<0I�>[ϾW����$����>�ve���8=jTþȚ�̣Z>��>ZГ��a>Pq>�6r��콻���H;���E�{�Z?p=��c<WG����?>��=E�E>�Q=>�5��bI�� �M���`�����-��a��=׏;@�C�߳m��c��r$��� ��+�Rsܽ!��i���݅�C���P������n=�=��b����D�<u��=���>�3�����닼���y�P��I=�yn��9������\U<�!~��о�<>�zP��o,�k)��C潤e�����[T�����=}��:���S'�%h�ה�>��\�������N�JSu���>"{����,&���;R<����L���
���?�q���.E�{�V�I�����a?�|���2��(?!�����7RU�%ig?k�Y��ͽ���s��M������1��^�c`�=s<&���8-��S��9�>�5þR�m��DM��K���A���{���B�S��깨=�]߽-�D��AȽ�uU<UEĽ�Wý��	�1�n�+�D���>�F�=^��O�ɽ�'��@��o���.D�*Ư�չ���ES��+�=�5ɽ� �
`=���ƽ� >�Ĵ<��������>!v��� �=	*��Z];F@-�O@X�$��{�=�%=h
=����n�;<G��<�b׽����t轑�=U�HS2��m�=���<����I�=?d6��}��哊=�0�܍�=J6 >�Ɔ��>��0��8���{�ƽ��ҽǆ������=��V��8�����.��]�O�	>M葼A;�> ْ>���&��������}�K >}%ӿ�y��>2������5S>=�>��K8*n]���>�aɿ<娾h�;��5a?
�G�Oځ�u�M=&����������<P�����<��>{#񼣌��	�ɼZ��<-��=���c�u=�l	��o�=y�̽df��s�=��=�8���
>�C����X;dT3�/u#��1�=\�3���ʽ�s���C�� �=��h꺼�p��h��=�!!�$'y=��H��pҽ��-�X���w.����M�߾\�8���Խu�N��"�=G֢�2���/?�K��^���t>��>ׁ=��/�X�R�1I��<�E=�^��n����J?-����>�������)��-?�ŽI�%�X�?�m���9u�b!2����=���X����M >��#�"��d��ܽ�%>Ҙ�<�����=4c������h>�v�����gI=�=w����#�>�iTy=�@�=te��:(f����<o��<%��������=����w߽X�1����.=�V=v,��=�5»cG<,,c�1(:>@Z>�}>2½ ��f�(<O=�u�=�>�=3�~�)�>�.>w?��> `=#����v�>�1¼�Ș�� >�?W>�V/?2��;�;+D'?���>�Hu>kp�>�>��>?�� >��H,-=�>>m޾KCw��,&>�v~����F-�;��D����=�_%�p��<�x�y�=-HB=ݪ���i�2��=Q��	��-�=J��S���>��-��X>C��J��= .�=~/�;���p��R1=��T�&�P� �PE8=kT�;c���'M��� �=�ſ<�/H���u��4�f�E��Q>�Ƚw>�G�<CzE���=��{�WO��@H^��=�c���+=�m0=b`����ÿ�D���Ld�ANѻ���?�>��»�yq�:� �A�>��=���<�-����ҿ����Ƒ�=�Mm�X�|��ϗ=�N�<�[��` >7 t�V�:�$Vͼ�>N=���=T�ݽޮ�������=�ri=s���u�� �٥T�N^ż�K�G����췼�.��{�==p=E�&U���|�=�h�<���"����H=�u��8����i<oq=���=��Q�߃F�4c ���=�J��{��������>b|�=�肾~�x��>����x�о�b���X��v��5ɼ���J���zq��i`��x=󂖾I0�N�^���m�o�<Y�3�F�>=���=jqR���w���Q~g��������������G�=���;Կ�<�KW���B���D��~;��~�����%�>�(����1"=�'�=��>�G>��>��V=�x�<��&���<�~��=�*��R�򭞽��=2�ڽj���y�=���=GϽ&���2>A�"��Mm����&�	�ܽ��=������=X����:��D��~�=G����P��A �T'�b��=ކ��p�ٽ� ļ/���ὖ=F�a�V>���8*� 5��8&�<	4�>��E��L���J��%���>+�ؽ5���b�/��e��9Yx<�z��b�=r�ؽ�P�;�=�W�=��"a����9>�qv<�l=!Z;"��:������C�ʶǽ��=`��ۿ����,��0��=�ᶼn�e���t�G�_�ӏż�������?�O:���'���b���̗���L_�LG��'C��|>z��[�t�]/�= ��?��n��Ó;Ry�=[Cվ'm`?M�[=5�O��jf�g��N#&�ֆ�>l�C��岽2FL�E<��Z��Xvt���=�9>�+�=��׽�_1��A���+�_��ĩ���f$�t�������۽��>¯�=e����������Q;f�q����t�0F�<�m��3�>ԲL�$�-?���ō��uL>�����	=��Ǿ0�>P>�n�;�Ǽ��3�ݜ����-���z�a�л{�=���J�!��=#�<��0!��%�>��8>[s>�X>=�q���Xѽ�_����"��<����_����սHt�}�->����C>�U	<|_A�a�>�#<*���'.q<�h�"z����ݽ
�ﾘR>G�<3P_���<%y�=����yI�lˀ��Pz�!M�<�D��z� ���0}k=��߽(𽷔�=�UeU��7��p�=�E���w=G<���� ��5���=Oٗ=
1��iZ>܏<j�,�>�FB����� üぽ����=k�O��>'��L��0R> =ļ�;н�0�*{@<|v��3����ӈ�>�X<��}=�Q?>J��C>ߵa�X< ��c�=�>�a׻�}�:�(.�X�о�,>����9G,�b_��"u�=8��<��U���2>����S��q�T>J�V��e��rJ=f8d�Q1��W�{�o���	!�u0r�Z�\�n��=="4����=��x�9�=t���q?������iO����=f8<�V�<�3���N�:Zd=6��U���)=;���4��;%�<+������,=�=c4�Ҍ��3 �J2�<\�ھW�ʽљ��B��<�()��/K��}[��p$��㩾1�ýP����������_>�=LǍ���FG��E�>r����{�.�쾐%L>$N����=F���
��m��>�.���o��W!> �2>�WA�G�p�l���5�>��v$@�Ȫ==�	K-�|/N��ϓ=~�<�?�����=���x=�҅��s��Fn�������5?L�K��µ�v��=Z<�=)F�<`��>}5?���<�?�Y�<�X�=�d,���@=1#�;��>��l���J=��>A�0>���>
�>HzL=4
�>�k?>?�����ս��=��>�;���^�<-��=)���_�=�ҥ�z��=&d�H�!x%��-ܽn�����n�Sb����=����H� ��^�=��?6�E=�qr�$Ws���=�JO�L,�r�o��ѿ�þ���=���v<���>�'��N�< �$� ;=O��K���
��=��e��m	�b�������	��^ɽׯ>�p�='{#<,���	���>Y��۽p>�?�d��=V;��証���=�`>F*����S�>�Ѭ;�A>�I����$���4�P�N�G�B�w����>)�> ꟼ���=eư�ٶ���� �F�E�8�R|Q�a��r��=^R=!/���ʿ��ݾ��=���hn������oؾ;�>l]���q���㑾�`V>8�+>�豼���?y���vӾ�����U�����==܄)�~�н��6���w>[g�� ^l�z?z���t�6�>��{=�>Q���<��<HP�=ɗ�1��{ɩ���}���F<q7;��pk>b0A��績OÑ��Y�lpe�]������DO�<z��>�`�>nlN=X�?��><=6=:�T�FR�<4~_�"�z>=��W���"^�T�>�i��ȃ��� �?s9+=�w��;�A�ˮ�>�5��M��LIj>SK(>��������~Cɿ_w�D��<�?�Jm�=mZ>��=-a�=wJ���ݾ��=s��U}�ҹ1��.�#�F�+���"��4��<��NTK?����}܆��7�>��O��ق�؃��h�=6�@������]%�l��>���=G�$�"lH�΁�>�񜽜�>�&�?�݅�(����n���ܽ����(>9C�P�<�zҽ&��3S!=l0���G.��
=h#�<�F���=؈�<%`�=�pn��>3�׫�;���j=n�*�ފ���������=J���F\�=F��h,d=���wg=�9*�(�f�z.�=��=T����<L�?=⺂���m����=�d�9�b�E��N��t�=����u=\��U�A�
<�|�<�����߼��K��\N�b`�!���ܥW=���<>2���]v�vۨ=�|)��C� � =�8�<�|ս�l��5W��(=�KU�6�AW��~<'��⢼)Ñ�